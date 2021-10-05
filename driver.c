#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include "hwlib.h"
#include "socal/hps.h"
#include "socal/alt_gpio.h"
#include "hps_0.h"

enum{ins_idle, ins_rst, ins_load, ins_key,
     ins_text, ins_crypt, ins_textout, ins_read};

volatile unsigned int*control; // memory-mapped register for control

volatile unsigned int*data_in; // memory-mapped register for data_in

volatile unsigned int*data_out; // memory-mapped register for data_out

void init() {
    control  = (unsigned int*) 0x80000000;
    data_in  = (unsigned int*) 0x80000004;
    data_out = (unsigned int*) 0x80000008;
}

void set_key(unsigned key[4]) {
    unsigned i;

    for(i=0;i<4;i++) {
        *control = ins_idle;
        *data_in = key[i];
        *control = (i == 3) ? ins_key : ins_load;
    }
}

void do_encrypt(unsigned plaintext[4],
                unsigned ciphertext[4]) {
    unsigned i;
    for(i=0; i<4; i++) {
        *control = ins_idle;
        *data_in = plaintext[i];
        *control = (i == 3) ? ins_text : ins_load;
    }
    *control = ins_idle; //set readCount to 0
    *control = ins_crypt;
    for(i=0;i<4;i++) {
        *control = ins_idle;
        *control = (i == 0) ? ins_textout : ins_read;
        ciphertext[i] =*data_out;
    }
}

char ** slice(char * str){
    unsigned i;
    unsigned j;

    char ** ret = malloc(32*sizeof(char));
    int x = 0;
    for(i = 0; i < 4; i++){
        for(j = 0; j < 8; j++){
            ret[i][j] = str[x];
            x++;
        }
    }
    return ret;
}

int main(int argc, char * argv[]){

    char * plaintext = argv[1];
    char * key = argv [2];
    unsigned keyArr[4];
    unsigned wordArr[4];
    unsigned outWord[4];

    char ** plainSec = slice(plaintext);
    char ** keySec = slice(key);

    unsigned i;
    for(i = 0; i < 4; i++){
        keyArr[i] = strtol(keySec[i], NULL, 16);
        wordArr[i] = strtol(plainSec[i], NULL, 16);
    }

    init();
    set_key(keyArr);
    do_encrypt(wordArr, outWord);

    return 0;
}
