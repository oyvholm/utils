/*
 * io.c
 * File ID: STDuuidDTS
 *
 * (C)opyleft STDyearDTS- Øyvind A. Holm <sunny@sunbase.org>
 *
 * This program is free software; you can redistribute it and/or modify it 
 * under the terms of the GNU General Public License as published by the Free 
 * Software Foundation; either version 2 of the License, or (at your option) 
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for 
 * more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "STDexecDTS.h"

/*
 * streams_init() - Initialize a `struct streams` struct. Returns nothing.
 */

void streams_init(struct streams *dest)
{
	binbuf_init(&dest->in);
	binbuf_init(&dest->out);
	binbuf_init(&dest->err);
	dest->ret = 0;
}

/*
 * streams_free() - Deallocate and set a `struct streams` struct to default 
 * values. Returns nothing.
 */

void streams_free(struct streams *dest)
{
	binbuf_free(&dest->in);
	binbuf_free(&dest->out);
	binbuf_free(&dest->err);
	streams_init(dest);
}

/*
 * read_from_fp() - Read data from fp into an allocated buffer and return a 
 * pointer to the allocated memory or NULL if something failed.
 */

char *read_from_fp(FILE *fp, struct binbuf *dest)
{
	struct binbuf buf;
	size_t bufsize = BUFSIZ;

	assert(fp);

	binbuf_init(&buf);

	do {
		char *p = NULL;
		char *new_mem = realloc(buf.buf, bufsize + buf.len);
		size_t bytes_read;

		if (!new_mem) {
			myerror("%s(): Cannot allocate" /* gncov */
			        " memory for stream buffer", __func__);
			binbuf_free(&buf); /* gncov */
			return NULL; /* gncov */
		}
		buf.alloc = bufsize + buf.len;
		buf.buf = new_mem;
		p = buf.buf + buf.len;
		bytes_read = fread(p, 1, bufsize - 1, fp);
		buf.len += bytes_read;
		p[bytes_read] = '\0';
		if (ferror(fp)) {
			myerror("%s(): Read error", __func__); /* gncov */
			binbuf_free(&buf); /* gncov */
			return NULL; /* gncov */
		}
	} while (!feof(fp));

	if (dest)
		*dest = buf;

	return buf.buf;
}

/*
 * prepare_valgrind_cmd() - Creates command array for valgrind execution. 
 * Returns a new allocated array that starts with `valgrind_args` followed by 
 * `cmd`. Returns NULL on error. Caller must free the returned array after use.
 */

static char **prepare_valgrind_cmd(char *cmd[]) /* gncov */
{
	static const char *valgrind_args[] = {
		"valgrind",
		"-q",
		"--leak-check=full",
		"--show-leak-kinds=all",
		"--"
	};
	const size_t argnum = sizeof(valgrind_args) /* gncov */
	                      / sizeof(valgrind_args[0]);
	size_t cmd_len = 0; /* gncov */
	char **valgrind_cmd;

	while (cmd[cmd_len]) /* gncov */
		cmd_len++; /* gncov */
	valgrind_cmd = malloc((cmd_len + argnum + 1) /* gncov */
	                      * sizeof(char *)); /* gncov */
	if (!valgrind_cmd) { /* gncov */
		myerror("%s(): malloc() failed", __func__); /* gncov */
		return NULL; /* gncov */
	}

	memcpy(valgrind_cmd, valgrind_args, /* gncov */
	       argnum * sizeof(char *)); /* gncov */
	memcpy(valgrind_cmd + argnum, cmd, /* gncov */
	       (cmd_len + 1) * sizeof(char *)); /* gncov */

	return valgrind_cmd; /* gncov */
}

/*
 * streams_exec() - Execute a command and store stdout, stderr and the return 
 * value into `dest`. `cmd` is an array of arguments, and the last element must 
 * be NULL. The return value is somewhat undefined at this point in time.
 */

int streams_exec(struct streams *dest, char *cmd[])
{
	int retval = 1;
	int infd[2] = { -1, -1 };
	int outfd[2] = { -1, -1 };
	int errfd[2] = { -1, -1 };
	pid_t pid;
	FILE *infp = NULL, *outfp = NULL, *errfp = NULL;
	struct sigaction old_action, new_action;

	assert(cmd);
	if (opt.verbose >= 10) {
		int i = -1; /* gncov */

		fprintf(stderr, "# %s(", __func__); /* gncov */
		while (cmd[++i]) /* gncov */
			fprintf(stderr, "%s\"%s\"", /* gncov */
			                i ? ", " : "", cmd[i]); /* gncov */
		fprintf(stderr, ")\n"); /* gncov */
	}

	if (pipe(infd) == -1) {
		myerror("%s():%d: Failed to create input pipe", /* gncov */
		        __func__, __LINE__);
		goto cleanup; /* gncov */
	}
	if (pipe(outfd) == -1) {
		myerror("%s():%d: Failed to create output pipe", /* gncov */
		        __func__, __LINE__);
		goto cleanup; /* gncov */
	}
	if (pipe(errfd) == -1) {
		myerror("%s():%d: Failed to create error pipe", /* gncov */
		        __func__, __LINE__);
		goto cleanup; /* gncov */
	}

	if ((pid = fork()) == -1) {
		myerror("%s():%d: fork() failed", /* gncov */
		        __func__, __LINE__);
		goto cleanup; /* gncov */
	}

	if (!pid) {
		/* Child */
		close(STDIN_FILENO);
		close(STDOUT_FILENO);
		close(STDERR_FILENO);
		if (dup2(infd[0], STDIN_FILENO) == -1
		    || dup2(outfd[1], STDOUT_FILENO) == -1
		    || dup2(errfd[1], STDERR_FILENO) == -1) {
			myerror("%s():%d: dup2() failed", /* gncov */
			        __func__, __LINE__);
			_exit(EXIT_FAILURE); /* gncov */
		}

		close(infd[0]);
		close(infd[1]);
		close(outfd[0]);
		close(outfd[1]);
		close(errfd[0]);
		close(errfd[1]);

		if (opt.valgrind) { /* gncov */
			char **valgrind_cmd
			= prepare_valgrind_cmd(cmd); /* gncov */
			execvp(valgrind_cmd[0], valgrind_cmd); /* gncov */
			free(valgrind_cmd); /* gncov */
		} else {
			execvp(cmd[0], cmd); /* gncov */
		}

		myerror("%s():%d: execvp() failed", /* gncov */
		        __func__, __LINE__);
		_exit(EXIT_FAILURE); /* gncov */
	}

	/* Parent */
	close(infd[0]);
	close(outfd[1]);
	close(errfd[1]);

	if (!dest) {
		wait(&retval); /* gncov */
		goto cleanup; /* gncov */
	}

	if (!(infp = fdopen(infd[1], "w"))
	    || !(outfp = fdopen(outfd[0], "r"))
	    || !(errfp = fdopen(errfd[0], "r"))) {
		myerror("%s():%d: fdopen() failed", /* gncov */
		        __func__, __LINE__);
		goto cleanup; /* gncov */
	}

	if (dest->in.buf && dest->in.len)
		fwrite(dest->in.buf, 1, dest->in.len, infp);
	read_from_fp(errfp, &dest->err);
	read_from_fp(outfp, &dest->out);
	msg(10, "%s():%d: dest->out.buf = \"%s\"",
	        __func__, __LINE__, dest->out.buf);
	msg(10, "%s():%d: dest->err.buf = \"%s\"",
	        __func__, __LINE__, dest->err.buf);

	wait(&dest->ret);
	dest->ret = dest->ret >> 8;
	retval = dest->ret;

cleanup:
	/* Protect against SIGPIPE when closing streams */
	new_action.sa_handler = SIG_IGN;
	sigemptyset(&new_action.sa_mask);
	new_action.sa_flags = 0;
	if (sigaction(SIGPIPE, &new_action, &old_action) == -1) {
		myerror("%s():%d: Failed to set SIGPIPE handler", /* gncov */
		        __func__, __LINE__);
	}

	if (errfp)
		fclose(errfp);
	if (outfp)
		fclose(outfp);
	if (infp)
		fclose(infp);
	if (infd[1] != -1)
		close(infd[1]);
	if (outfd[0] != -1)
		close(outfd[0]);
	if (errfd[0] != -1)
		close(errfd[0]);

	/* Restore original signal handling */
	if (sigaction(SIGPIPE, &old_action, NULL) == -1) {
		myerror("%s():%d: Failed to restore" /* gncov */
		        " SIGPIPE handler", __func__, __LINE__);
	}

	return retval;
}

/* vim: set ts=8 sw=8 sts=8 noet fo+=w tw=79 fenc=UTF-8 : */
