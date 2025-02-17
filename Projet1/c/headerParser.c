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
    uint8_t is_vararg_flag;
    uint8_t maximum_stack_size;
} LuaStaticFunctionBlock;

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

void print_static_function_block(const LuaStaticFunctionBlock *func) {
    printf("Source Name: %s\n", func->source_name ? func->source_name : "(none)");
    printf("Line Defined: %u\n", func->line_defined);
    printf("Last Line Defined: %u\n", func->last_line_defined);
    printf("Number of Upvalues: %u\n", func->number_of_upvalues);
    printf("Number of Parameters: %u\n", func->number_of_parameters);
    printf("Is Vararg Flag: %u\n", func->is_vararg_flag);
    printf("Maximum Stack Size: %u\n", func->maximum_stack_size);
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

int parse_static_function_block(FILE *file, LuaStaticFunctionBlock *static_function_block) {
    // Lecture de la source (nom de la source)
    size_t source_name_length;
    if (fread(&source_name_length, sizeof(size_t), 1, file) != 1) {
        fprintf(stderr, "Error reading source name length\n");
        return -1;
    }

    printf("Source size: %ld\n", source_name_length);

    // Allouer de la mémoire pour la source_name en fonction de la longueur lue
    static_function_block->source_name = malloc(source_name_length);
    if (!static_function_block->source_name) {
        fprintf(stderr, "Memory allocation failed for source name\n");
        return -1;
    }

    // Lire le nom de la source
    if (fread(static_function_block->source_name, sizeof(char), source_name_length, file) != source_name_length) {
        fprintf(stderr, "Error reading source name\n");
        free(static_function_block->source_name);  // Libérer la mémoire en cas d'erreur
        return -1;
    }
    static_function_block->source_name[source_name_length] = '\0';  // Ajouter le caractère nul de fin

    // Lire le reste du bloc de fonction statique
    if (fread(&static_function_block->line_defined, sizeof(uint32_t), 1, file) != 1) {
        fprintf(stderr, "Error reading line_defined\n");
        free(static_function_block->source_name);  // Libérer la mémoire en cas d'erreur
        return -1;
    }
    
    if (fread(&static_function_block->last_line_defined, sizeof(uint32_t), 1, file) != 1) {
        fprintf(stderr, "Error reading last_line_defined\n");
        free(static_function_block->source_name);  // Libérer la mémoire en cas d'erreur
        return -1;
    }

    if (fread(&static_function_block->number_of_upvalues, sizeof(uint8_t), 1, file) != 1) {
        fprintf(stderr, "Error reading number_of_upvalues\n");
        free(static_function_block->source_name);  // Libérer la mémoire en cas d'erreur
        return -1;
    }

    if (fread(&static_function_block->number_of_parameters, sizeof(uint8_t), 1, file) != 1) {
        fprintf(stderr, "Error reading number_of_parameters\n");
        free(static_function_block->source_name);  // Libérer la mémoire en cas d'erreur
        return -1;
    }

    if (fread(&static_function_block->is_vararg_flag, sizeof(uint8_t), 1, file) != 1) {
        fprintf(stderr, "Error reading is_vararg_flag\n");
        free(static_function_block->source_name);  // Libérer la mémoire en cas d'erreur
        return -1;
    }

    if (fread(&static_function_block->maximum_stack_size, sizeof(uint8_t), 1, file) != 1) {
        fprintf(stderr, "Error reading maximum_stack_size\n");
        free(static_function_block->source_name);  // Libérer la mémoire en cas d'erreur
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

    LuaStaticFunctionBlock static_function_block;
    if (parse_static_function_block(file, &static_function_block) == 0) {
        print_static_function_block(&static_function_block);
    }
    
    fclose(file);
    return 0;
}
