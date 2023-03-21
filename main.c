#include <sys/wait.h>
#include <sys/types.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <limits.h>
#include  <signal.h>
#include <stdbool.h>
#include <libgen.h>
#include <readline/readline.h>
#include <readline/history.h>

// The original path we start in goes here
char cwd[1024];

// Built ins
int shell_cd(char **args);
int shell_help(char **args);
int shell_exit(char **args);

void exit_prompt(int sig) {
    signal(sig, SIG_IGN);
}

bool strpref(const char *str, const char *pre)
{
    size_t lenpre = strlen(pre),
           lenstr = strlen(str);
    return lenstr < lenpre ? false : memcmp(pre, str, lenpre) == 0;
}


int shell_cd(char **args)
{
  if (args[1] == NULL) {
    chdir(cwd);
  } else {
    // Make sure the path is within our jail
    char * abspath = realpath(args[1], NULL);
    if (abspath == NULL) {
        fprintf(stderr, "bastille: cant cd to %s\n", args[1]);
        return 1;
    }
    if (!strpref(abspath, cwd)) {
        // cant cd to a directory that isnt a subdir of the jail
        fprintf(stderr, "bastille: cant cd to %s\n", abspath);
        return 1;
    }
    printf("abs is %s\n", abspath);
    free(abspath);
    if (chdir(args[1]) != 0) {
      perror("bastille");
    }
  }
  return 1;
}

int bastille_launch(char **args)
{
  pid_t pid;
  int status;

  pid = fork();
  if (pid == 0) {
    // Child process
    if (execvp(args[0], args) == -1) {
      perror("bastille");
    }
    exit(EXIT_FAILURE);
  } else if (pid < 0) {
    // Error forking
    perror("bastille");
  } else {
    // Parent process
    do {
      waitpid(pid, &status, WUNTRACED);
    } while (!WIFEXITED(status) && !WIFSIGNALED(status));
  }

  return 1;
}

int shell_help(char **args) {
    printf("env\ncd\nhelp\nexit\n");
    return 1;
}

int bastille_execute(char **args, char **envp)
{
    // An empty command was entered.
    if (args[0] == NULL) {
        return 1;
    }

    for (int i = 0; i < 19; i++) {
        if (args[i] == NULL) {
            break;
        }
        if (strstr(args[i], "flag") != NULL) {
            fprintf(stderr, "%s: no such file or directory\n", args[0]);
            return 1;
        }
    }

    if (args[0][0] == '.' || args[0][0] == '/') {
        fprintf(stderr, "%s: no such file or directory\n", args[0]);
        return 1;
    }

    if (strcmp(args[0], "cd") == 0) {
        return shell_cd(args);
    } else if (strcmp(args[0], "help") == 0) {
        return shell_help(args);
    } else if (strcmp(args[0], "exit") == 0) {
        return 0;
    } else if (strcmp(args[0], "exit") == 0) {
        return 0;
    } else if (strcmp(args[0], "env") == 0) {
        for (char **env = envp; *env != 0; env++)
        {
            char *thisEnv = *env;
            printf("%s\n", thisEnv);    
        }
        return 1;
    }
    return bastille_launch(args);
}

char * _read_line(void)
{
  char *line = NULL;
  ssize_t bufsize = 0; // have getline allocate a buffer for us
  if (getline(&line, &bufsize, stdin) == -1) {
    if (feof(stdin)) {
      exit(EXIT_SUCCESS);  // We received an EOF
    } else  {
      perror("bastille: getline\n");
      exit(EXIT_FAILURE);
    }
  }
  return line;
}

#define bastille_TOK_BUFSIZE 64
#define bastille_TOK_DELIM " \t\r\n\a"
/**
   @brief Split a line into tokens (very naively).
   @param line The line.
   @return Null-terminated array of tokens.
 */
char **bastille_split_line(char *line)
{
  int bufsize = bastille_TOK_BUFSIZE, position = 0;
  char **tokens = malloc(bufsize * sizeof(char*));
  char *token, **tokens_backup;

  if (!tokens) {
    fprintf(stderr, "bastille: allocation error\n");
    exit(EXIT_FAILURE);
  }

  token = strtok(line, bastille_TOK_DELIM);
  while (token != NULL) {
    if (token[0] == '$') {
        tokens[position] = getenv((char *)(token+1));
    } else {
        tokens[position] = token;
    }

    position++;

    if (position >= bufsize) {
      bufsize += bastille_TOK_BUFSIZE;
      tokens_backup = tokens;
      tokens = realloc(tokens, bufsize * sizeof(char*));
      if (!tokens) {
		free(tokens_backup);
        fprintf(stderr, "bastille: allocation error\n");
        exit(EXIT_FAILURE);
      }
    }

    token = strtok(NULL, bastille_TOK_DELIM);
  }
  tokens[position] = NULL;
  return tokens;
}

void bastille_loop(char **envp)
{
    char *line;
    char **args;
    int status;
    char curr[1024];
    char prompt[1024];
    do {
        getcwd(curr, 1024);
        snprintf(prompt, 1024, "[bastille] %s > ", basename(curr));
        //line = _read_line();
        line = readline(prompt);
        add_history(line);
        args = bastille_split_line(line);
        status = bastille_execute(args, envp);
        free(line);
        free(args);
    } while (status);
}

int main(int argc, char **argv, char **envp)
{
    signal(SIGINT, exit_prompt);
    getcwd(cwd, sizeof(cwd));
    bastille_loop(envp);
    return EXIT_SUCCESS;
}

