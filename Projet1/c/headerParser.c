#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#define LUA_SIGNATURE "\x1bLua"
#define HEADER_SIZE 12

// Structure du header en fonction du header block
typedef struct {
    char signature[4];
    uint8_t version;
    uint8_t format;
    char endianness;
    uint8_t int_size;
    uint8_t size_t_size;
    uint8_t instruction_size;
    uint8_t lua_number_size;
    uint8_t integral_flag;
} LuaHeader;

typedef struct {
    char* source_name;
    uint32_t line_defined;
    uint32_t last_line_defined;
    uint8_t number_of_upvalues;
    uint8_t number_of_parameters;
    

} LuaFunctionBlock;

void print_header(const LuaHeader *header) {
    printf("Lua Version: %d\n", header->version);
    printf("Format: %d\n", header->format);
    printf("Endianness: %s\n", header->endianness ? "Little" : "Big");
    printf("Integer Size: %d\n", header->int_size);
    printf("Size_t Size: %d\n", header->size_t_size);
    printf("Instruction Size: %d\n", header->instruction_size);
    printf("Lua Number Size: %d\n", header->lua_number_size);
    printf("Integral Flag: %d\n", header->integral_flag);
}

int parse_header(FILE *file, LuaHeader *header) {
    if (fread(header, sizeof(LuaHeader), 1, file) != 1) {
        fprintf(stderr, "Error reading header\n");
        return -1;
    }
    if (memcmp(header->signature, LUA_SIGNATURE, 4) != 0) {
        fprintf(stderr, "Invalid Lua signature\n");
        return -1;
    }
    return 0;
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <bytecode file>\n", argv[0]);
        return 1;
    }
    
    FILE *file = fopen(argv[1], "rb");
    if (!file) {
        perror("Error opening file");
        return 1;
    }
    
    LuaHeader header;
    if (parse_header(file, &header) == 0) {
        print_header(&header);
    }
    
    fclose(file);
    return 0;
}
