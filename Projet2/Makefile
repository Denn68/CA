LEX_ML = ocamllex
YACC_ML = ocamlyacc
OCAMLC = ocamlc
OCAMLFLAGS = -g

# Executables
EXEC_INTERP = caml_interpreter
EXEC_COMP = caml_compiler
EXEC_CAMTOECLAT = caml_to_eclat

# Sources communs
SRC_COMMON = caml_compiler.ml lexer.mll parser.mly

# Générés automatiquement
GEN = lexer.ml parser.ml parser.mli

# Objets communs
OBJ_COMMON = caml_compiler.cmo parser.cmo lexer.cmo

# Objets spécifiques
OBJ_INTERP = $(OBJ_COMMON) caml_interpreter.cmo
OBJ_COMP = $(OBJ_COMMON) main.cmo
OBJ_CAMTOECLAT = $(OBJ_COMMON) caml_to_eclat.cmo

all: $(EXEC_INTERP) $(EXEC_COMP) $(EXEC_CAMTOECLAT)

# Génération lexer.ml
lexer.ml: lexer.mll
	$(LEX_ML) lexer.mll

# Génération parser.ml et parser.mli
parser.ml parser.mli: parser.mly
	$(YACC_ML) -v parser.mly

# Compilation modules
caml_compiler.cmo: caml_compiler.ml
	$(OCAMLC) $(OCAMLFLAGS) -c caml_compiler.ml

parser.cmo: parser.ml parser.mli
	$(OCAMLC) $(OCAMLFLAGS) -c parser.mli
	$(OCAMLC) $(OCAMLFLAGS) -c parser.ml

lexer.cmo: lexer.ml
	$(OCAMLC) $(OCAMLFLAGS) -c lexer.ml

caml_interpreter.cmo: caml_interpreter.ml
	$(OCAMLC) $(OCAMLFLAGS) -c caml_interpreter.ml

main.cmo: main.ml
	$(OCAMLC) $(OCAMLFLAGS) -c main.ml

caml_to_eclat.cmo: caml_to_eclat.ml
	$(OCAMLC) $(OCAMLFLAGS) -c caml_to_eclat.ml

# Lien des exécutables
$(EXEC_INTERP): $(OBJ_INTERP)
	$(OCAMLC) -o $(EXEC_INTERP) $(OBJ_INTERP)

$(EXEC_COMP): $(OBJ_COMP)
	$(OCAMLC) -o $(EXEC_COMP) $(OBJ_COMP)

$(EXEC_CAMTOECLAT): $(OBJ_CAMTOECLAT)
	$(OCAMLC) -o $(EXEC_CAMTOECLAT) $(OBJ_CAMTOECLAT)

clean:
	rm -f *.cmo *.cmi *.o *.annot $(EXEC_INTERP) $(EXEC_COMP) $(EXEC_CAMTOECLAT)
	rm -f parser.ml parser.mli parser.output lexer.ml
