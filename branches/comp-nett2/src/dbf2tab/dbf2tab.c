#include <stdio.h>
#include <strings.h>
#define  MAXSTR 512
#define  INTEL
#define  min(x,y) (x < y ? x : y)
#define  max(x,y) (x > y ? x : y)

/*
  Structure of DBF files (dBASE III)
  Header Structure
  0000  1 byte    03h for .DBF w/out memo (.DBT). 83h for with .DBT file
  0001  3 bytes   date of last update YY MM DD
  0004  2 words   number of records in data file (32 bit number)
  0008  1 word    number bytes in header
  000A  1 word    number bytes in data record
  000C  3 bytes   reserved
  000F  13 bytes  reserved for dBASE III PLUS on network
  001C  2 words   reserved
  0020  32 bytes  1st element of field descriptor array
  ....
        1 byte    0Dh field terminator
        (Foxpro dbf has a null byte immediately after field terminator)
  
  Field Descriptor Array
    00  11 bytes  Field name in ASCII (zero filled)
    0B  1 byte    Field type in ASCII (C, N, L, D or M)
    0C  2 words   Field data address (address set in memory not useful on disk)
    10  1 byte    Field length
    11  1 byte    Field decimal count
    12  2 bytes   reserved for network
    14  1 byte    Work area ID
    15  1 word    reserved for network
    17  1 byte    SET FIELDS flag
    18  8 bytes   reserved

  Copied from a program written by G. Patterson, 1988
  (Orginally copied from dBASE III technical specs)

  */

FILE  *dfile;
int   status = 0;                       /* status byte from fread     */
int   l_flag = 0;                       /* list .DBF info (yes/no)    */
int   num_fields;			/* no of fields in .DBF       */
int   deleted = 0;			/* no of deleted recs in .DBF */
char  fnam[1024];                       /* file spec of .DBF file     */
char* rec_buf;                          /* buffer for .DBF records    */

struct DBF_HEAD {
	unsigned char dbf_info;
	unsigned char date[3];
	unsigned int num_recs;
	unsigned short head_len;
	unsigned short rec_len;
	unsigned char filler[20];
};

struct DBF_HEAD dbf_head;

struct FIELD_DESC {
	char name[11];
	char type;
	unsigned char filler1[4];
	unsigned char len;
	unsigned char decimals;
	unsigned char filler2[14];
};

struct FIELD_DESC *field;

#ifndef INTEL
#define iSHORT(i) (unsigned short) ( (i&0xff)<<8) | ( (i&0xff00)>>8)
#define iLONG(i) (unsigned) ( (i&0xff)<<24) | ( (i&0xff00)<<8) | ( (i&0xff0000)>>8) | ( (i&0xff000000)>>24)
#endif

/* ------------------------------------------------------------------------- */

char *rtrim( s)
char *s;
{
	char *ptr;
	static char t[MAXSTR];

	strncpy( t, s, sizeof( t) );
	t[ sizeof(t ) - 1 ] = '\0';
	for( ptr = t + max( 0, strlen( t) - 1); ptr >= t; ptr--)
		if ( *ptr == ' ' )
			*ptr = '\0';
		else
			break;
	return( t);
}

/* ------------------------------------------------------------------------- */

char *ltrim( s)
char *s;
{
	char *ptr;
	static char t[MAXSTR];

	for( ptr = s; *ptr != '\0'; ptr++)
		if ( *ptr != ' ' )
			break;
	strncpy( t, ptr, sizeof( t) );
	t[ sizeof(t ) - 1 ] = '\0';
	return( t);
}

/* ------------------------------------------------------------------------- */

fatal_err( msg)
char *msg;
{
	fprintf(stderr,"\ndbf2tab: %s\n", msg);
	exit(1);
}

/* ------------------------------------------------------------------------- */

get_header()
/*
 * read the dbf header
 */
{
	int i;
	char t_buf[MAXSTR];
	char *t;

	/* first, get the 32 byte header at start of file */
	if ( (status = fread(t_buf, 1, 32, dfile) ) == 0 )
		fatal_err( "can't read header");
	memcpy( (char *)(&dbf_head), t_buf, 32);
#ifndef INTEL
	/* ------------------------------------------------------------ */
	/* if this is compiled on non-INTEL, must flip bytes            */
	/* ok, this is an un-subtle slegehammer kludge -- but it works  */
	/* ------------------------------------------------------------ */
	dbf_head.num_recs = iLONG( dbf_head.num_recs);
	dbf_head.head_len = iSHORT( dbf_head.head_len);
	dbf_head.rec_len = iSHORT( dbf_head.rec_len);
#endif
	num_fields = dbf_head.head_len/32 - 1;

	/* load the field desriptor array */
	if ( ( t = (char *)malloc( dbf_head.head_len - 32 ) ) == NULL)
		fatal_err("can't malloc space for field descriptor array");
	field = (struct FIELD_DESC *)t;
	if ( (status = fread( (char *)field, 1, dbf_head.head_len - 32, dfile) ) == 0)
		fatal_err( "invalid header");
	/* allocate space for the record_buffer */
	if ( (rec_buf = (char *)malloc( dbf_head.rec_len + 1 ) ) == NULL)
		fatal_err( "can't malloc space for record buffer" );
	if ( l_flag)
	{
		printf( "%s:\n", fnam);
		printf("\nField       T Len Dec\n" );
		printf(  "-----       - --- ---\n" );
		for ( i = 0; i < num_fields; i++)
		{
			printf( "%-11s %c %3d", field[i].name, field[i].type,
				field[i].len );
			if ( field[i].decimals != 0 ) 
				printf( " %3d\n", field[i].decimals );
			else
				printf( "\n" );
		}
	}
	else
	{
		/* print the header line (fields names) */
		for ( i = 0; i < num_fields; i++)
			if ( field[i].type != 'M' )
			{
				if (field[i].len >= MAXSTR )
					fatal_err( "must increase MAXSTR and re-compile");
				field[i].name[10] = '\0';
				if ( i > 0 )
					printf( "\t" );
				printf( "%s", field[i].name );
			}
		printf( "\n" );
	}
}

/* ------------------------------------------------------------------------- */

get_rec()
/*
 * get the next record from .DBF file into rec_buf buffer
 */
{
	char *ptr;
	char t[MAXSTR];
	int i;

	if ( (status = fread(rec_buf, 1, dbf_head.rec_len, dfile) ) == 0 )
		return(1);
	if ( rec_buf[0] == '*' )
	{
		deleted++;
		return( 0);
	}
	if ( l_flag )
		return( 0);
	/* print each record as series of fields seperated by TAB */
	ptr = rec_buf + 1;
	for ( i = 0; i < num_fields; i++)
	{
		/* skip Memo fields */
		if ( field[i].type != 'M' )
		{
			strncpy( t, ptr, field[i].len);
			t[field[i].len] = '\0';
			if ( field[i].type == 'N' )
				strcpy( t, ltrim( t) );
			if ( i > 0 )
				printf( "\t");
			printf( "%s", rtrim( t) );
		}
		ptr += field[i].len;
	}
	printf( "\n");
	return( 0);
}

/* ------------------------------------------------------------------------- */

usage()
{
	fprintf(stderr,"\nusage:\n");
	fprintf(stderr,"\tdbf2tab [-l] dbffile\n");
	fprintf(stderr,"\twhere dbffile is the file spec of an xBASE .DBF file\n" );
	fprintf(stderr,"\n" );
	exit(1);
}

/* ------------------------------------------------------------------------- */

main(argc, argv)
    int     argc;
    char    *argv[];
{
	/* parse the command line */
	if (argc == 3)
	{
		if ( strcmp ("-l", argv[1]) )
			usage();
		strcpy (fnam, argv[2]);
		l_flag++;
	}
	else if ( argc == 2 )
		strcpy (fnam, argv[1]);
	else
		usage();
	if ( (dfile = fopen( fnam, "rb") ) == NULL)
		strcat( fnam, ".dbf" );
	if ( (dfile = fopen( fnam, "rb") ) == NULL)
		usage();

	/* process the .DBF file, read the header and then each record */
	get_header();
	while (!get_rec() );

	/* clean up and exit */
	if ( l_flag )
	{
		printf( "\nModDate: %d/%d/%d  HeadLen: %d  RecLen: %d  Fields: %d\n",
			dbf_head.date[2],
			dbf_head.date[1],
			dbf_head.date[0],
			dbf_head.head_len,
			dbf_head.rec_len,
			num_fields );
		printf( "NumRecs: %d\nDeleted: %d\n\n", dbf_head.num_recs, deleted );
	}
	fclose(dfile);
	free( (char *) field);
	exit(0);
}
