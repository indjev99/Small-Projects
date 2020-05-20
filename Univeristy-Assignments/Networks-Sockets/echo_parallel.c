#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#include <string.h>

#define PORT    56789           /* default port number for the echo service */
#define BSIZE   11              /* artificially short buffer size           */

#define PROMPT  "Networks Practical Echo Server\n"
#define QUIT    ".\r\n"
#define ENDLN   '\n'

#define QUIT_LEN 3

#define TRUE    (0==0)

int main(int argc, char *argv[]) {

    /* Read the port from the command-line (if given). */
    int port = argc < 2 ? PORT : atoi(argv[1]);  

    /* Inform the user what the program does and how it's used. */
    fprintf(stderr, "Starting an echo server on port: %d\nSet port with the first command-line argument.\n", port);

    int sock;                   /* file descriptor for the server socket */
    struct sockaddr_in server;
    int session_num = -1;       /* keeps track of the current session number */

    char buf[BSIZE];
    
    /* 1. Create socket*/

    if ((sock = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
        perror("cannot open a socket");
        exit(EXIT_FAILURE);
    };

    /* 2. Bind an address at the socket*/

    server.sin_family = AF_INET;
    server.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
    server.sin_port = htons(port);

    if (bind(sock, (struct sockaddr *) &server, sizeof(server)) < 0) {
        perror("bind");
        exit(EXIT_FAILURE);
    };

    /* 3. Accept connections*/

    if (listen(sock, 32) < 0) {
        perror("listen");
        exit(EXIT_FAILURE);
    };

    while (TRUE) {

    /* 4. Wait for client requests*/
       
        struct sockaddr_in client;
        socklen_t client_len = sizeof(client);
        int stream = accept(sock, (struct sockaddr *) &client, &client_len);

        if (stream < 0) {
            perror("accept");
            exit(EXIT_FAILURE);
        }

        ++session_num;

        int pid = fork();

        if (pid < 0) {
            perror("fork");
            exit(EXIT_FAILURE);
        }

        /* The parent just accepts requests, it doesn't handle sessions. */
        if (pid != 0) {
            exit(0);
            continue;
        }

        if (send(stream, PROMPT, 31, 0) < 0) {
            close(stream);
            exit(EXIT_FAILURE);
        }

        int size;

        /* Repeat while there is incoming text. */
        do {

            if ((size = recv(stream, buf, BSIZE - 1, 0)) < 0) {
                perror("recv");
                exit(EXIT_FAILURE);
            }

            buf[size] = '\0';                    /* null-termination for strings */
            fprintf(stderr, "%d. Text received: %s\n", session_num, buf);

            if (send(stream, buf, size, 0) < 0) {
                perror("send");
                exit(EXIT_FAILURE);
            }

        } while (size > 0);

        close(stream);

        /* The child handles just one session and then kills itself. */
        exit(0);
    
    }; /* while(TRUE) */

    return 0;

}; /* main */
