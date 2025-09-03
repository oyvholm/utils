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
 * file_exists() - Returns `true` if a filesystem entry (file, directory, 
 * symlink, etc.) exists at path `s`, or `false` if it does not. Symlinks are 
 * treated as ordinary entries, so if the symlink exists but is broken, the 
 * function still returns `true`.
 */

bool file_exists(const char *s)
{
	struct stat st;

	assert(s);
	assert(*s);

	if (lstat(s, &st)) {
		if (errno == ENOENT)
			errno = 0;
		return false;
	}

	return true;
}

/*
 * streams_init() - Initializes a `struct streams` struct. Returns nothing.
 */

void streams_init(struct streams *dest)
{
	assert(dest);

	binbuf_init(&dest->in);
	binbuf_init(&dest->out);
	binbuf_init(&dest->err);
	dest->ret = 0;
}

/*
 * streams_free() - Deallocates and sets a `struct streams` struct to default 
 * values. Returns nothing.
 */

void streams_free(struct streams *dest)
{
	assert(dest);

	binbuf_free(&dest->in);
	binbuf_free(&dest->out);
	binbuf_free(&dest->err);
	streams_init(dest);
}

/*
 * read_from_fp() - Reads data from fp into an allocated buffer and returns a 
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
			binbuf_free(&buf); /* gncov */
			return NULL; /* gncov */
		}
	} while (!feof(fp));

	if (dest)
		*dest = buf;

	return buf.buf;
}

/*
 * create_file() - Create file `file` and write the string `txt` to it. If any 
 * error occurred, NULL is returned. Otherwise, it returns `txt`. If `txt` is 
 * NULL, an empty file is created and an empty string is returned.
 */

const char *create_file(const char *file, const char *txt)
{
	const char *retval = NULL;
	FILE *fp = NULL;

	assert(file);
	assert(*file);

	fp = fopen(file, "w");
	if (!fp)
		return NULL;
	if (txt) {
		int i;

		i = fputs(txt, fp);
		if (i == EOF)
			goto out; /* gncov */
		retval = txt;
	} else {
		retval = "";
	}

out:
	fclose(fp);

	return retval;
}

/*
 * read_from_file() - Read contents of file `fname` and return a pointer to a 
 * allocated string with the contents, or NULL if error.
 */

char *read_from_file(const char *fname)
{
	FILE *fp;
	char *retval;

	assert(fname);
	assert(*fname);

	fp = fopen(fname, "rb");
	if (!fp)
		return NULL;
	retval = read_from_fp(fp, NULL);
	fclose(fp);

	return retval;
}

/*
 * prepare_valgrind_cmd() - Creates a command array for valgrind execution. 
 * Returns a new allocated array that starts with `valgrind_args` followed by 
 * `cmd`. Returns NULL on error. Caller must free the returned array after use.
 */

static char **prepare_valgrind_cmd(char *cmd[]) /* gncov */
{
	static const char *valgrind_args[] = {
		"valgrind",
		"-q",
		"--error-exitcode=1",
		"--leak-check=full",
		"--show-leak-kinds=all",
		"--"
	};
	const size_t argnum = sizeof(valgrind_args) /* gncov */
	                      / sizeof(valgrind_args[0]);
	size_t cmd_len = 0; /* gncov */
	char **valgrind_cmd;

	assert(cmd); /* gncov */
	while (cmd[cmd_len]) /* gncov */
		cmd_len++; /* gncov */
	valgrind_cmd = malloc((cmd_len + argnum + 1) /* gncov */
	                      * sizeof(char *));
	if (!valgrind_cmd) { /* gncov */
		failed("malloc()"); /* gncov */
		return NULL; /* gncov */
	}

	memcpy(valgrind_cmd, valgrind_args, /* gncov */
	       argnum * sizeof(char *));
	memcpy(valgrind_cmd + argnum, cmd, /* gncov */
	       (cmd_len + 1) * sizeof(char *)); /* gncov */

	return valgrind_cmd; /* gncov */
}

/*
 * write_stdin_to_child() - Writes `len` bytes from `buf` to `fp` and uses a 
 * loop to make sure the whole input is received by the child process. Returns 
 * 0 if successful, or 1 if write() fails.
 */

static int write_stdin_to_child(const int fd, const char *buf, /* gncov */
                                const size_t len)
{
	size_t total_written = 0; /* gncov */

	assert(buf); /* gncov */

	while (total_written < len) { /* gncov */
		ssize_t written = write(fd, buf + total_written, /* gncov */
		                        len - total_written);

		if (written == -1) { /* gncov */
			if (errno == EINTR) /* gncov */
				continue; /* gncov */
			failed("write() to stdin pipe"); /* gncov */
			return 1; /* gncov */
		}
		total_written += (size_t)written; /* gncov */
	}

	return 0; /* gncov */
}

/*
 * streams_exec() - Executes a command and stores stdout, stderr and the return 
 * value into `dest`. `cmd` is an array of arguments, and the last element must 
 * be NULL. Returns the exit value from the process.
 */

int streams_exec(const struct Options *o, struct streams *dest, char *cmd[])
{
	int retval = 1;
	int infd[2] = { -1, -1 };
	int outfd[2] = { -1, -1 };
	int errfd[2] = { -1, -1 };
	pid_t pid;
	FILE *outfp = NULL, *errfp = NULL;
	struct sigaction old_action, new_action;

	assert(o);
	assert(dest);
	assert(cmd);

	if (o->verbose >= 10) {
		int i = -1; /* gncov */

		fprintf(stderr, "# %s(", __func__); /* gncov */
		while (cmd[++i]) /* gncov */
			fprintf(stderr, "%s\"%s\"", /* gncov */
			                i ? ", " : "", cmd[i]); /* gncov */
		fprintf(stderr, ")\n"); /* gncov */
	}

	if (pipe(infd) == -1) {
		failed("Creation of stdin pipe"); /* gncov */
		goto cleanup; /* gncov */
	}
	if (pipe(outfd) == -1) {
		failed("Creation of stdout pipe"); /* gncov */
		goto cleanup; /* gncov */
	}
	if (pipe(errfd) == -1) {
		failed("Creation of stderr pipe"); /* gncov */
		goto cleanup; /* gncov */
	}

	if ((pid = fork()) == -1) {
		failed("fork()"); /* gncov */
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
			failed("dup2()"); /* gncov */
			_exit(EXIT_FAILURE); /* gncov */
		}

		close(infd[0]);
		close(infd[1]);
		close(outfd[0]);
		close(outfd[1]);
		close(errfd[0]);
		close(errfd[1]);

		if (o->valgrind) { /* gncov */
			char **valgrind_cmd
			= prepare_valgrind_cmd(cmd); /* gncov */
			execvp(valgrind_cmd[0], valgrind_cmd); /* gncov */
			free(valgrind_cmd); /* gncov */
		} else {
			execvp(cmd[0], cmd); /* gncov */
		}

		failed("execvp()"); /* gncov */
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

	if (!(outfp = fdopen(outfd[0], "r"))
	    || !(errfp = fdopen(errfd[0], "r"))) {
		failed("fdopen()"); /* gncov */
		goto cleanup; /* gncov */
	}

	/* Write to stdin using direct write() call and close immediately */
	if (dest->in.buf && dest->in.len) {
		if (write_stdin_to_child(infd[1], dest->in.buf, /* gncov */
			                 dest->in.len)) {
			goto cleanup; /* gncov */
		}
	}
	close(infd[1]);
	infd[1] = -1;

	/* Now read from stdout and stderr */
	read_from_fp(errfp, &dest->err);
	read_from_fp(outfp, &dest->out);
	msg(10, "%s():%d: dest->out.buf = \"%s\"",
	        __func__, __LINE__, no_null(dest->out.buf));
	msg(10, "%s():%d: dest->err.buf = \"%s\"",
	        __func__, __LINE__, no_null(dest->err.buf));

	wait(&dest->ret);
	dest->ret = dest->ret >> 8;
	retval = dest->ret;

cleanup:
	/* Protect against SIGPIPE when closing streams */
	new_action.sa_handler = SIG_IGN;
	sigemptyset(&new_action.sa_mask);
	new_action.sa_flags = 0;
	if (sigaction(SIGPIPE, &new_action, &old_action) == -1)
		failed("Cannot set SIGPIPE handler, sigaction()"); /* gncov */

	if (errfp)
		fclose(errfp);
	if (outfp)
		fclose(outfp);
	if (infd[1] != -1)
		close(infd[1]); /* gncov */

	/* Restore original signal handling */
	if (sigaction(SIGPIPE, &old_action, NULL) == -1)
		failed("Restoration of SIGPIPE handler"); /* gncov */

	return retval;
}

/* vim: set ts=8 sw=8 sts=8 noet fo+=w tw=79 fenc=UTF-8 : */
