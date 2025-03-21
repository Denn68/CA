#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <stdbool.h>

#define LUA_MAGIC "\x1bLua"
#define MAX_CONSTANTS 256
#define MAX_INSTRUCTIONS 256
#define MAX_LOCALS 256
#define MAX_UPVALUES 256
#define MAX_PROTOS 256
#define MAX_LINES 256

// Types d'instructions Lua
typedef enum {
    ABC,
    ABx,
    AsBx
} InstructionType;

// Structure d'une instruction
typedef struct {
    InstructionType type;
    char name[16];
    uint8_t opcode;
    uint8_t A;
    uint16_t B;
    uint16_t C;
    uint32_t Bx; 
} Instruction;

// Structure d'une constante
typedef struct {
    uint8_t type;
    union {
        double number;
        char *string;
        bool boolean;
    } value;
} Constant;

// Structure d'une variable locale
typedef struct {
    char *name;
    uint32_t start_pc;
    uint32_t end_pc;
} Local;

// Structure d'une upvalue
typedef struct {
    char *name;
} Upvalue;

// Structure d'un chunk (fonction Lua compilée)
typedef struct Chunk Chunk;


struct Chunk {
    char *name;
    uint32_t first_line;
    uint32_t last_line;
    uint8_t numUpvals;
    uint8_t numParams;
    bool isVarg;
    uint8_t maxStack;
    
    Instruction instructions[MAX_INSTRUCTIONS];
    uint32_t instruction_count;

    Constant constants[MAX_CONSTANTS];
    uint32_t constant_count;

    Local locals[MAX_LOCALS];
    uint32_t local_count;
    
    Upvalue upvalues[MAX_UPVALUES];
    uint32_t upvalue_count;
    
    uint32_t source_lines[MAX_LINES];
    uint32_t line_count;

    Chunk *protos[MAX_PROTOS];
    uint32_t proto_count;
};

// Table des noms des opcodes
const char *opcode_names[] = {
    "MOVE", "LOADK", "LOADBOOL", "LOADNIL", "GETUPVAL", "GETGLOBAL", "GETTABLE",
    "SETGLOBAL", "SETUPVAL", "SETTABLE", "NEWTABLE", "SELF", "ADD", "SUB", "MUL",
    "DIV", "MOD", "POW", "UNM", "NOT", "LEN", "CONCAT", "JMP", "EQ", "LT", "LE",
    "TEST", "TESTSET", "CALL", "TAILCALL", "RETURN", "FORLOOP", "FORPREP", "TFORLOOP",
    "SETLIST", "CLOSE", "CLOSURE", "VARARG"
};

// Fonction pour lire un entier 32 bits
uint32_t read_uint32(FILE *file) {
    uint32_t value;
    fread(&value, sizeof(uint32_t), 1, file);
    return value;
}

// Fonction pour lire un octet
uint8_t read_byte(FILE *file) {
    uint8_t value;
    fread(&value, sizeof(uint8_t), 1, file);
    return value;
}

// Fonction pour lire une chaîne de caractères
char* read_string(FILE *file) {
    size_t string_length;
    if (fread(&string_length, sizeof(size_t), 1, file) != 1) {
        fprintf(stderr, "Error reading string length\n");
        return "";
    }

    char* string;
    string = malloc(string_length + 1);
    if (!string) {
        fprintf(stderr, "Memory allocation string\n");
        return "";
    }

    if (fread(string, sizeof(char), string_length, file) != string_length) {
        fprintf(stderr, "Error reading string\n");
        free(string);  // Libérer la mémoire en cas d'erreur
        return "";
    }
    string[string_length] = '\0';  // Ajouter le caractère nul de fin

    return string;
}

// Fonction de décodage d'une instruction
Instruction decode_instruction(uint32_t data) {
    Instruction instr;
    instr.opcode = data & 0x3F;
    instr.A = (data >> 6) & 0xFF;
    instr.C = (data >> 14) & 0x1FF;
    instr.B = (data >> 23) & 0x1FF;
    instr.Bx = (data >> 14);
    return instr;
}

// Fonction pour dumper une instruction
void dump_instruction(Instruction instr) {
    printf("Instruction: %10s A: %d B: %d C: %d\n", opcode_names[instr.opcode], instr.A, instr.B, instr.C);
}

// Fonction pour charger un chunk Lua depuis un fichier
Chunk* load_chunk(FILE *file) {
    Chunk *chunk = malloc(sizeof(Chunk));
    chunk->name = read_string(file);
    chunk->first_line = read_uint32(file);
    chunk->last_line = read_uint32(file);
    chunk->numUpvals = read_byte(file);
    chunk->numParams = read_byte(file);
    chunk->isVarg = read_byte(file) != 0;
    chunk->maxStack = read_byte(file);

    chunk->instruction_count = read_uint32(file);
    for (uint32_t i = 0; i < chunk->instruction_count; i++) {
        uint32_t instr_data = read_uint32(file);
        chunk->instructions[i] = decode_instruction(instr_data);
    }

    chunk->constant_count = read_uint32(file);
    for (uint32_t i = 0; i < chunk->constant_count; i++) {
        chunk->constants[i].type = read_byte(file);
        if (chunk->constants[i].type == 3) {
            fread(&chunk->constants[i].value.number, sizeof(double), 1, file);
        } else if (chunk->constants[i].type == 4) {
            chunk->constants[i].value.string = read_string(file);
        } else if (chunk->constants[i].type == 1) {
            chunk->constants[i].value.boolean = read_byte(file) != 0;
        }
    }
    
    chunk->proto_count = read_uint32(file);
    for (uint32_t i = 0; i < chunk->proto_count; i++) {
        chunk->protos[i] = load_chunk(file);
    }

    chunk->line_count = read_uint32(file);
    for (uint32_t i = 0; i < chunk->line_count; i++) {
        chunk->source_lines[i] = read_uint32(file);
    }
    
    chunk->local_count = read_uint32(file);
    for (uint32_t i = 0; i < chunk->local_count; i++) {
        chunk->locals[i].name = read_string(file);
        chunk->locals[i].start_pc = read_uint32(file);
        chunk->locals[i].end_pc = read_uint32(file);
    }
    
    chunk->upvalue_count = read_uint32(file);
    for (uint32_t i = 0; i < chunk->upvalue_count; i++) {
        chunk->upvalues[i].name = read_string(file);
    }

    return chunk;
}

// VM pour l'execution du bytecode
// Définition des fonctions natives (GETGLOBAL/print)
typedef void (*NativeFunction)(double *args, int n_args);

typedef enum {
    VAL_NUMBER,
    VAL_NATIVE,
    VAL_CLOSURE
} ValueType;

typedef struct {
    ValueType type;
    union {
        double number;
        NativeFunction native;
        Chunk *closure;
    } as;
} VMValue;

typedef struct {
    const char *name;
    NativeFunction function;
} GlobalFunction;

void native_print(double *args, int n_args) {
    for (int i = 0; i < n_args; i++) {
        printf("%f ", args[i]);
    }
    printf("\n");
}

GlobalFunction globals[] = {
    {"print", native_print}
};
#define NUM_GLOBALS (sizeof(globals) / sizeof(globals[0]))

// Structure VM
typedef struct {
    VMValue registers[256];
    Constant *constants;
    Instruction *instructions;
    uint32_t instruction_count;
    Chunk **protos;
    uint32_t proto_count;
} VM;

double call_prototype(Chunk *proto, double *args, int nargs) {
    VMValue registers[256] = {0};
    for (int i = 0; i < nargs && i < proto->numParams; i++) {
        registers[i].type = VAL_NUMBER;
        registers[i].as.number = args[i];
    }

    for (uint32_t pc = 0; pc < proto->instruction_count; pc++) {
        Instruction instr = proto->instructions[pc];
        switch (instr.opcode) {
            case 12:
                registers[instr.A].type = VAL_NUMBER;
                registers[instr.A].as.number = registers[instr.B].as.number + registers[instr.C].as.number;
                break;
            case 30:
                return registers[instr.A].as.number;
        }
    }
    return 0.0;
}

void vm_execute(VM *vm) {
    for (uint32_t pc = 0; pc < vm->instruction_count; pc++) {
        Instruction instr = vm->instructions[pc];
        switch (instr.opcode) {
            case 0:
                vm->registers[instr.A] = vm->registers[instr.B];
                break;
            case 1:
                vm->registers[instr.A].type = VAL_NUMBER;
                vm->registers[instr.A].as.number = vm->constants[instr.Bx].value.number;
                break;
            case 5: {
                if (instr.Bx < MAX_CONSTANTS && vm->constants[instr.Bx].type == 4) {
                    char *name = vm->constants[instr.Bx].value.string;
                    for (int i = 0; i < NUM_GLOBALS; i++) {
                        if (strcmp(globals[i].name, name) == 0) {
                            vm->registers[instr.A].type = VAL_NATIVE;
                            vm->registers[instr.A].as.native = globals[i].function;
                            break;
                        }
                    }
                }
                break;
            }
            case 12:
                vm->registers[instr.A].type = VAL_NUMBER;
                vm->registers[instr.A].as.number = vm->registers[instr.B].as.number + vm->registers[instr.C].as.number;
                break;
            case 28: {
                VMValue func = vm->registers[instr.A];
                int n_args = instr.B - 1;
                double args[10];
                for (int i = 0; i < n_args; i++) {
                    args[i] = vm->registers[instr.A + 1 + i].as.number;
                }

                if (func.type == VAL_CLOSURE) {
                    double result = call_prototype(func.as.closure, args, n_args);
                    if (instr.C > 1) {
                        vm->registers[instr.A].type = VAL_NUMBER;
                        vm->registers[instr.A].as.number = result;
                    }
                } else if (func.type == VAL_NATIVE) {
                    func.as.native(args, n_args);
                }
                break;
            }
            case 30:
                return;
            case 36:
                vm->registers[instr.A].type = VAL_CLOSURE;
                vm->registers[instr.A].as.closure = vm->protos[instr.B];
                break;
            default:
                printf("Opcode non pris en charge : %s\n", opcode_names[instr.opcode]);
                break;
        }
    }
}

// Fonction principale
int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("Usage: %s <luac file> [--dump]\n", argv[0]);
        return 1;
    }

    FILE *file = fopen(argv[1], "rb");
    if (!file) {
        perror("Erreur d'ouverture du fichier");
        return 1;
    }

    // Lire et vérifier la signature Lua
    char magic[4];
    fread(magic, 1, 4, file);
    if (memcmp(magic, LUA_MAGIC, 4) != 0) {
        printf("Fichier non valide : ce n'est pas un bytecode Lua.\n");
        fclose(file);
        return 1;
    }

    // Lire l'en-tête du fichier
    uint8_t version = read_byte(file);
    uint8_t format = read_byte(file);
    uint8_t endianess = read_byte(file);
    uint8_t int_size = read_byte(file);
    uint8_t size = read_byte(file);
    uint8_t instr_size = read_byte(file);
    uint8_t number_size = read_byte(file);
    uint8_t integral_flag = read_byte(file);

    printf("HEADER \n");
    printf("\n");
    printf("Lua Version: %.1f\n", version / 16.0);
    printf("Format: %d\n", format);
    printf("Endianness: %s\n", endianess ? "Little" : "Big");
    printf("Integer Size: %d\n", int_size);
    printf("Size_t Size: %d\n", size);
    printf("Instruction Size: %d\n", instr_size);
    printf("Lua Number Size: %d\n", number_size);
    printf("Integral Flag: %d\n", integral_flag);
    printf("\n");



    // Charger le chunk principal
    Chunk *chunk = load_chunk(file);
    fclose(file);

    printf("STATIC FUNCTION BLOCK\n");
    printf("\n");
    printf("Source Name: %s\n", chunk->name ? chunk->name : "(none)");
    printf("Line Defined: %u\n", chunk->first_line);
    printf("Last Line Defined: %u\n", chunk->last_line);
    printf("Number of Upvalues: %u\n", chunk->numUpvals);
    printf("Number of Parameters: %u\n", chunk->numParams);
    printf("Is Vararg Flag: %u\n", chunk->isVarg);
    printf("Maximum Stack Size: %u\n", chunk->maxStack);
    printf("Number of Instructions: %u\n", chunk->instruction_count);
    printf("Number of Constants: %u\n", chunk->constant_count);
    printf("Number of Locals: %u\n", chunk->local_count);
    printf("Number of Upvalues: %u\n", chunk->upvalue_count);
    printf("Number of Source Lines: %u\n", chunk->line_count);
    printf("\n");

    // Afficher les instructions
    printf("\n=== PARSING de %s ===\n", chunk->name ? chunk->name : "<main>");
    for (uint32_t i = 0; i < chunk->instruction_count; i++) {
        printf("[%3d] OP: %2d A: %3d B: %3d C: %3d\n", i, chunk->instructions[i].opcode,
               chunk->instructions[i].A, chunk->instructions[i].B, chunk->instructions[i].C);
    }

    // Afficher les constantes
    printf("\n=== Constantes ===\n");
    for (uint32_t i = 0; i < chunk->constant_count; i++) {
        printf("Const[%3d] Type: %d\n", i, chunk->constants[i].type);
        switch (chunk->constants[i].type) {
            case 0: printf("Constant does not exist\n"); break;
            case 1: printf("Boolean: %s\n", chunk->constants[i].value.boolean ? "true" : "false"); break;
            case 3: printf("Number: %f\n", chunk->constants[i].value.number); break;
            case 4: printf("String: %s\n", chunk->constants[i].value.string); break;
            default : printf("Unknown type\n"); break;
        }
    }

    // Afficher les variables locales
    printf("\n=== Locals ===\n");
    for (uint32_t i = 0; i < chunk->local_count; i++) {
        printf("Local[%3d] Name: %s, Start: %u, End: %u\n", i, chunk->locals[i].name, chunk->locals[i].start_pc, chunk->locals[i].end_pc);
    }

    // Afficher les upvalues
    printf("\n=== Upvalues ===\n");
    for (uint32_t i = 0; i < chunk->upvalue_count; i++) {
        printf("Upvalue[%3d] Name: %s\n", i, chunk->upvalues[i].name);
    }

    // Afficher les lignes sources
    printf("\n=== Source Lines ===\n");
    for (uint32_t i = 0; i < chunk->line_count; i++) {
        printf("Line[%3d]: %u\n", i, chunk->source_lines[i]);
    }

    printf("\n=== Prototypes de fonctions ===\n");
    for (uint32_t i = 0; i < chunk->proto_count; i++) {
        printf("Prototype %d\n", i);
        printf("Source Name: %s\n", chunk->protos[i]->name ? chunk->protos[i]->name : "(none)");
        printf("Line Defined: %u\n", chunk->protos[i]->first_line);
        printf("Last Line Defined: %u\n", chunk->protos[i]->last_line);
        printf("Number of Upvalues: %u\n", chunk->protos[i]->numUpvals);
        printf("Number of Parameters: %u\n", chunk->protos[i]->numParams);
        printf("Is Vararg Flag: %u\n", chunk->protos[i]->isVarg);
        printf("Maximum Stack Size: %u\n", chunk->protos[i]->maxStack);
        printf("Number of Instructions: %u\n", chunk->protos[i]->instruction_count);
        printf("Number of Constants: %u\n", chunk->protos[i]->constant_count);
        printf("Number of Locals: %u\n", chunk->protos[i]->local_count);
        printf("Number of Upvalues: %u\n", chunk->protos[i]->upvalue_count);
        printf("Number of Source Lines: %u\n", chunk->protos[i]->line_count);

        // Afficher les instructions
        printf("\n=== PARSING de %s ===\n", chunk->protos[i]->name ? chunk->protos[i]->name : "prototype");
        for (uint32_t j = 0; j < chunk->protos[i]->instruction_count; j++) {
            printf("[%3d] OP: %2d A: %3d B: %3d C: %3d\n", j, chunk->protos[i]->instructions[j].opcode,
                chunk->protos[i]->instructions[j].A, chunk->protos[i]->instructions[j].B, chunk->protos[i]->instructions[j].C);
        }

        // Afficher les constantes
        printf("\n=== Constantes ===\n");
        for (uint32_t j = 0; j < chunk->protos[i]->constant_count; j++) {
            printf("Const[%3d] Type: %d\n", j, chunk->protos[i]->constants[j].type);
            switch (chunk->protos[i]->constants[j].type) {
                case 0: printf("Constant does not exist\n"); break;
                case 1: printf("Boolean: %s\n", chunk->protos[i]->constants[j].value.boolean ? "true" : "false"); break;
                case 3: printf("Number: %f\n", chunk->protos[i]->constants[j].value.number); break;
                case 4: printf("String: %s\n", chunk->protos[i]->constants[j].value.string); break;
                default : printf("Unknown type\n"); break;
            }
        }

        // Afficher les variables locales
        printf("\n=== Locals ===\n");
        for (uint32_t j = 0; j < chunk->protos[i]->local_count; j++) {
            printf("Local[%3d] Name: %s, Start: %u, End: %u\n",
                j, chunk->protos[i]->locals[j].name, 
                chunk->protos[i]->locals[j].start_pc, chunk->protos[i]->locals[j].end_pc);
        }

        // Afficher les upvalues
        printf("\n=== Upvalues ===\n");
        for (uint32_t j = 0; j < chunk->protos[i]->upvalue_count; j++) {
            printf("Upvalue[%3d] Name: %s\n", j, chunk->protos[i]->upvalues[j].name);
        }

        // Afficher les lignes sources
        printf("\n=== Source Lines ===\n");
        for (uint32_t j = 0; j < chunk->protos[i]->line_count; j++) {
            printf("Line[%3d]: %u\n", j, chunk->protos[i]->source_lines[j]);
        }

        // Dumping
        if (argc > 2 && strcmp(argv[2], "--dump") == 0) {
            printf("\n=== DUMPING ===\n");
            for (uint32_t j = 0; j < chunk->protos[i]->instruction_count; j++) {
                dump_instruction(chunk->protos[i]->instructions[j]);
            }
        }
    }

    // Dumping
     if (argc > 2 && strcmp(argv[2], "--dump") == 0) {
        printf("\n=== DUMPING ===\n");
        for (uint32_t i = 0; i < chunk->instruction_count; i++) {
            dump_instruction(chunk->instructions[i]);
        }
    }

    VM vm = {
    .constants = chunk->constants,
    .instructions = chunk->instructions,
    .instruction_count = chunk->instruction_count,
    .protos = chunk->protos,
    .proto_count = chunk->proto_count
    };

    printf("\n=== EXECUTION VM ===\n");
    vm_execute(&vm);

    printf("AFFICHAGE DES 3 PREMIERS REGISTRES\n");
    if (vm.registers[0].type == VAL_NUMBER)
        printf("Résultat (R(0)) = %f\n", vm.registers[0].as.number);
    if (vm.registers[1].type == VAL_NUMBER)
        printf("Résultat (R(1)) = %f\n", vm.registers[1].as.number);
    if (vm.registers[2].type == VAL_NUMBER)
        printf("Résultat (R(2)) = %f\n", vm.registers[2].as.number);
    
    free(chunk);
    return 0;
}
