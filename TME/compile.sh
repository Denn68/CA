#!/bin/sh

ocamllex lexer.mll;
ocamlc -c ast.ml;
ocamlc -c eval.ml;
ocamlc -c gen.ml;
ocamlyacc parser.mly;
ocamlc -c parser.mli;
ocamlc -c lexer.ml;
ocamlc -c parser.ml;
ocamlc -c calc.ml;
ocamlc -c calcToVm.ml;
ocamlc -o calc ast.cmo eval.cmo lexer.cmo parser.cmo calc.cmo;
ocamlc -o calcToVm ast.cmo gen.cmo lexer.cmo parser.cmo calcToVm.cmo;

