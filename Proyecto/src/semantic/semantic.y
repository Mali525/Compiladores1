%{

	void yyerror(char *msg);
	extern "C" int yylex();
	extern int yylineno;

	int current_label = 0;
	int current_func_label = 0;
	int current_index = 0;
	int current_temp  = 0;
	int current_dir  = 0;
	std::string new_label();
	std::string new_func_label();
	std::string new_index();
	std::string new_temp();
	bool verif_parametros(std::vector<simbolo> argu, std::vector<expresion> params);
	expresion *eval_func(std::vector<expresion> params, funcion f);

	void qprint(std::string s);

	int obtener_tam_basico(int tipo);

	int max(int t1, int t2);
	std::string ampliar(std::string dir, int t1, int t2, expresion *e);
	std::string reducir(std::string dir, int t1, int t2, expresion *e);
	expresion *get_num(numero *n);
	expresion *identificador(std::string id);

	std::vector<std::string> etiquetas;
	std::vector<cuadrupla> codigo_intermedio;
	tabla_simbolos tabla_de_simbolos;
	//std::string reducir(std::string dir, int t1, int t2);

	expresion *suma(expresion *e1, expresion *e2);
	expresion *resta(expresion *e1, expresion *e2);
	expresion *multiplicacion(expresion *e1, expresion *e2);
	expresion *division(expresion *e1, expresion *e2);
	expresion *modulo(expresion *e1, expresion *e2);
	expresion *get_cadena(cadena *c);

	tipo *tipo_actual = new tipo();


	// Funciones para verificar simbolos en los ambientes
	int var_esta_definida(std::string id);
	int get_direccion_simbolo(std::string id);
	tipo get_tipo_simbolo(std::string id);

	// Variables globales agregadas para el manejo de las funciones
	std::map<std::string,funcion> tabla_de_funciones;
	std::map<std::string,tabla_simbolos> tabla_de_struct;
	std::vector<simbolo> args;
	tabla_simbolos *respaldo_tabla_simbolos;

	//Utilidad para concatener vectors
	template<typename Type>
	std::vector<Type> concat(std::vector<Type> v1, std::vector<Type> v2);
	template<typename Type>
	std::vector<Type> concat(std::vector<Type> v, Type elem);
	template<typename Type>
	std::vector<Type> concat(Type elem, std::vector<Type> v);

	sentencia* crea_sentencia();

	std::vector<std::string> N_next_list;
	cuadrupla N_goto;
%}

%union vals {
	tipo *tipo_;
	expresion *expresion_;
	numero *numero_;
	std::string *id_;
	cadena *cadena_;
	relacionales rel;
	int dimens;
	std::vector<std::string> *lista_argumentos_;
	std::string *asignacion_;
	sentencia *sentencia_;
	condicion *condicion_;
	std::vector<expresion> *params_;
	std::string *m_;
	std::string *n_;
	var_arg *var_arg_;
}
 
%token<cadena_> CADENA
%token<id_> ID
%token TERM
%token LPAR
%token INT
%token FLOAT
%token DOUB
%token CHAR
%token VOID
%token FUNC
%token IF
%token ELSE
%token WHILE
%token RETURN
%token BREAK
%token PRINT
%token SWITCH
%token DO
%token COMA
%token TRU
%token FALS
%token DEFAULT
%token CASE
%token PUNTOS
%token ASIGN
%token STRUCT
%left NOT
%left AND
%left OR
%left MEN
%left MAY
%left LEQ
%left GEQ
%left DIF
%left EQ
%left MAS
%left RES
%left MULT
%left DIV
%left MOD
%nonassoc LPAR RPAR
%nonassoc LCOR RCOR
%nonassoc LLAV RLAV
%token COMENTARIO

%type<tipo_> tipo
%type<expresion_> expresion
%type<expresion_> parte_izquierda
%type<numero_> numeros
%type<rel> relacional
%type<tipo_> arreglo
//%type<id_> parte_izquierda
%type<asignacion_> asignacion
%type<sentencia_> sentencia
%type<condicion_> condicion
%type<dimens> parte_arreglo
%type<params_> parametros
%type<params_> lista_param
%type<var_arg_> var_arreglo
%type<dimens> Z
%type<m_> M
%type<n_> N
%destructor { delete $$; } <tipo_>
%destructor { delete $$; } <asignacion_>

%start programa

%%
programa :
declaraciones {
	imprime_tabla(tabla_de_simbolos);
} funciones {
	print_codigo(codigo_intermedio);
} ;

declaraciones :
tipo {
	current_dir = 0;
	tipo_actual = $1;
} lista TERM
| /* vacío */ ;

tipo :
INT    { $$ = new tipo(); $$->tipo = INT; $$ -> dim = 4; }
| FLOAT  { $$ = new tipo(); $$->tipo = FLOAT; $$ -> dim = 4; }
| DOUB   { $$ = new tipo(); $$->tipo = DOUB; $$ -> dim = 8;  }
| CHAR   { $$ = new tipo(); $$->tipo = CHAR; $$ -> dim = 1;  }
| VOID   { $$ = new tipo(); $$->tipo = VOID; $$ -> dim = 0;  }
| STRUCT LLAV Z declaraciones RLAV { 
	$$ = new tipo();
	$$->tipo = STRUCT;
	$$->dim = 0;
	std::pair<int, int> dat_struct;
	for (simbolo s : tabla_de_simbolos.simbolos) {
		$$ -> dim += s.t.dim;
		dat_struct.first = s.t.tipo;
		dat_struct.second = s.direccion;
		$$ -> datos_struct[s.id] = dat_struct;
	}
	tabla_de_simbolos = *respaldo_tabla_simbolos;
	respaldo_tabla_simbolos->clear();
	current_dir = $3;
};

/**
 * Produccion vacia para respaldar al tabla de simbolos
 **/
Z :
	{
	respaldo_tabla_simbolos = new tabla_simbolos(tabla_de_simbolos);
	tabla_de_simbolos.clear();
	$$ = current_dir;
	};

lista :
lista COMA ID arreglo {
	simbolo s;
	s.id = std::string(*$3);
	s.t = *$4;//*tipo_actual;
	s.direccion = current_dir;
	current_dir += $4 -> dim;
	tabla_de_simbolos.inserta(s);
}
| ID arreglo {
	simbolo s;
	s.id = std::string(*$1);
	s.t = *$2;//*tipo_actual;
	s.direccion = current_dir;
	current_dir += $2 -> dim;
	tabla_de_simbolos.inserta(s);
};

arreglo :
/* vacío */ {
	$$ = new tipo();
	$$ -> tipo = tipo_actual -> tipo;
	$$ -> dim = tipo_actual -> dim;
}
| LCOR numeros RCOR arreglo {
	if ($2 -> tipo == INT) {
	$$ = new tipo();
	$$ -> dimensiones.push_back(std::stoi($2 -> valor));
	if (!($4 -> dimensiones.empty())) {
		for (int i = 0; i < ($4 -> dimensiones.size()); i++)
			$$ -> dimensiones.push_back($4 -> dimensiones[i]);
	}
	$$ -> tipo = tipo_actual -> tipo;
	$$ -> dim = $4 -> dim * std::stoi($2 -> valor);
	}
};

funciones :
/* vacio */
| FUNC tipo ID LPAR argumentos RPAR LLAV declaraciones sentencia RLAV { 
	// agregar el simbolo de la funcion con el tipo a la tabla de simbolos
	funcion *f = new funcion();
	f -> argumentos = args;
	f -> tipo_r = $2 -> tipo;
	tabla_de_simbolos = *respaldo_tabla_simbolos;
	respaldo_tabla_simbolos->clear();
	args.clear();
	//Mete el código al vector global.
	std::string etiqueta_funcion = (*$3=="main")?"MAIN":new_func_label();
	codigo_intermedio.push_back(cuadrupla_label(etiqueta_funcion));
	codigo_intermedio = concat(codigo_intermedio,$9->code);
	f -> etiqueta = etiqueta_funcion;
	tabla_de_funciones[*$3] = *f;
	delete f;
	simbolo s;
	s.id = *$3;
	tipo *t = new tipo();
	t -> tipo = FUNC;
	s.t = *t;
	tabla_de_simbolos.inserta(s);
	delete t;
} funciones ;

argumentos :
/* vacio */ {
	/* Respalda la tabla de simbolos y genera una nueva global para la funcion */
	respaldo_tabla_simbolos = new tabla_simbolos(tabla_de_simbolos);
	tabla_de_simbolos.clear();
}
| lista_argumentos {
	/* Respalda la tabla de simbolos y genera una nueva global para la funcion */
	respaldo_tabla_simbolos = new tabla_simbolos(tabla_de_simbolos);
	tabla_de_simbolos.clear();
};

/** Por el momento ignora lo de arreglo y toma la variable ID como un tipo basico
 * definido en tipo
 **/
lista_argumentos :
lista_argumentos COMA tipo ID parte_arreglo {
	simbolo s;
	s.id = std::string(*$4);
	s.t = *$3;
	s.direccion = current_dir;
	current_dir += $3 -> dim;
	tabla_de_simbolos.inserta(s);
	args.push_back(s);
}
| tipo ID parte_arreglo {
	/* Primero llena el tipo básico antes de agregar lo de arreglo. */
	simbolo s;
	s.id = std::string(*$2);
	s.t = *$1;
	s.direccion = current_dir;
	current_dir += $1 -> dim;
	tabla_de_simbolos.inserta(s);
	args.push_back(s);
} ;

/** Se definio como un entero y solo cuenta las dimensiones del arreglo, otras
	* palabras cuenta el numero de []. Por el momento no tiene uso alguno
	 **/
parte_arreglo :
/* vacio */ {
	$$ = 0;
}
| LCOR RCOR parte_arreglo {
	$$ = $3;
};

sentencia :
sentencia sentencia {
	$$ = crea_sentencia();
	$1->next = new_index();
	$2->next = $$->next;
	$$->code = concat(concat($1->code, cuadrupla_label($1->next)), $2->code);
}
| IF LPAR condicion RPAR M sentencia {
	$$ = crea_sentencia();
	$3->code = backpatch($3->trues, *$5, $3->code);
	$$->next_list = merge($3->falses, $6->next_list);

	$3->t = new_index();
	$3->f = $$->next;
	$$->code = concat(concat($3->code, cuadrupla_label($3->t)), $6->code);
}
| IF LPAR condicion RPAR M sentencia N ELSE M sentencia {
	$$ = crea_sentencia();
	$3->code = backpatch($3->trues, *$5, $3->code);
	$3->code = backpatch($3->falses, *$9, $3->code);
	N_next_list.clear();
	N_next_list.push_back(*$7);
	std::vector<std::string> temp = merge($6->next_list, N_next_list);
	$$->next_list = merge(temp, $10->next_list);

	$3->t = new_index();
	$3->f = new_index();
	$6->next = $$->next;
	$10->next = $$->next;
	$$->code = concat(concat(concat(concat(concat(concat(
	                  $3->code,
	                  cuadrupla_label($3->t)),
	                  $6->code),
	                  cuadrupla_goto(*$7)),
	                  cuadrupla_goto($$->next)),
	                  cuadrupla_label($3->f)),
	                  $10->code);
}
| WHILE LPAR condicion RPAR sentencia {
	std::string begin = new_index();
	$$ = crea_sentencia();
	$3->t = new_index();
	$3->f = $$->next;
	$5->next = begin;
	$$->code = concat(concat(concat(concat(
	                  cuadrupla_label(begin),
	                  $3->code),
	                  cuadrupla_label($3->t)),
	                  $5->code),
	                  cuadrupla_goto(begin));
}
| DO sentencia WHILE LPAR condicion RPAR TERM {
	std::string begin = new_index();
	$$ = crea_sentencia();
	$5->t = new_index();
	$5->f = $$->next;
	$2->next = begin;
	$$->code = concat(concat(concat(concat(
	                  cuadrupla_label(begin),
	                  $2->code),
	                  $5->code),
	                  cuadrupla_label($5->t)),
	                  cuadrupla_goto(begin));
}
| parte_izquierda ASIGN expresion TERM {
	//WHAT?
	$$ = crea_sentencia();
	int tip = max($1 -> tipo, $3 -> tipo);
	if (tip == -1)
		yyerror( (char *) "Error semantico: tipos no compatibles");
	expresion e = (*$3); 
	std::string dir_cast = reducir(($3 -> direccion), ($1 -> tipo), ($3 -> tipo), &e);
	cuadrupla c = cuadrupla_asig($1 -> direccion, dir_cast);
	$$ -> code = concat(concat($1 -> code, e.code), c);
	//$$->code = $1->code;
	//$1->code = $3->code;
}
| RETURN expresion TERM {
	$$ = crea_sentencia();
	$$->code = $2->code;
}
| RETURN TERM {
	$$ = crea_sentencia();
	$$->code.push_back(cuadrupla_goto($$->next));
}
| LLAV sentencia RLAV {
	$$ = crea_sentencia();
	$$->code = $2->code;
	}
| SWITCH LPAR expresion RPAR LLAV casos predeterminado RLAV {
	// TODO
}
| BREAK TERM {
	$$ = crea_sentencia();
	$$->code.push_back(cuadrupla_goto($$->next));
}
| PRINT expresion TERM {
	$$ = crea_sentencia();
	$$->code = $2->code;
	$$->code.push_back(cuadrupla_print_dir($2->direccion));
} ;

casos :
/* vacio */
| CASE PUNTOS numeros sentencia predeterminado ;

predeterminado :
/* vacio */
| DEFAULT PUNTOS sentencia ;

parte_izquierda :
ID {
	if (var_esta_definida(*$1) == -1)
		yyerror( (char *) "Error semantico: el identificador no existe");
	expresion *e = new expresion();
	e -> direccion = std::to_string(get_direccion_simbolo(*$1));
	e -> tipo = get_tipo_simbolo(*$1).tipo;
	$$ = e;
	}

| var_arreglo {
	expresion *e = new expresion();
	e -> direccion = new_temp();
	e -> tipo = $1 -> exp.tipo;
	cuadrupla *c = new cuadrupla();
	c -> resultado = e -> direccion;
	c -> operacion = SUMA;
	c -> operando1 = std::to_string($1 -> direccion_base);
	c -> operando2 = $1 -> exp.direccion;
	e -> code = concat($1 -> exp.code, *c);
	$$ = e;};

var_arreglo :
ID LCOR expresion RCOR {
	if (var_esta_definida(*$1) == -1)
		yyerror( (char *) "Error semantico: el identificador no existe");
	tipo t = get_tipo_simbolo(*$1);
	if (t.dimensiones.empty())
		yyerror( (char *) "Error semantico: el identificador no corresponde a un arreglo");
	int pos = $3 -> tipo;
	int offset = obtener_tam_basico(t.tipo);
	std::vector<int> dims;
	for (int i = t.dimensiones.size() - 1; i > 0 ; i--) {
		dims.push_back(offset);
		offset = offset * t.dimensiones[i];
	}
	expresion *e = new expresion();
	e -> tipo = t.tipo;
	e -> direccion = new_temp();
	cuadrupla *c = new cuadrupla();
	c -> operacion = MULTIPLICACION;
	c -> resultado = e -> direccion;
	c -> operando1 = $3 -> direccion;
	c -> operando2 = std::to_string(offset);
	e -> code = concat($3 -> code, *c);
	var_arg *var = new var_arg();
	var -> exp = *e;
	var -> tams = dims;
	var -> direccion_base = get_direccion_simbolo(*$1);
	$$ = var;
		}
| var_arreglo LCOR expresion RCOR {
	std::string t1 = new_temp();
	std::string t2 = new_temp();
	var_arg *var = new var_arg();
	if ((*$1).tams.empty())
		yyerror( (char *) "Error semantico: el identificador no corresponde a un arreglo");
	std::vector<int> dimen = (*$1).tams;
	cuadrupla *c1 = new cuadrupla();
	cuadrupla *c2 = new cuadrupla();
	c1 -> resultado = t1;
	c1 -> operacion = MULTIPLICACION;
	c1 -> operando1 = $3 -> direccion;
	c1 -> operando2 = std::to_string(dimen[dimen.size() - 1]);
	c2 -> resultado = t2;
	c2 -> operacion = SUMA;
	c2 -> operando1 = ($1 -> exp).direccion;
	c2 -> operando2 = t1;
	expresion *e = new expresion();
	e -> tipo = ($1 -> exp).tipo;
	e -> direccion = t2;
	e -> code = concat(concat(($1 -> exp).code, *c1), *c2);
	dimen.pop_back();
	var -> tams = dimen;
	var -> exp = *e;
	var -> direccion_base = $1 -> direccion_base;
	$$ = var;
	} ;

expresion :
expresion MAS expresion    {$$ =suma($1, $3);}
| expresion RES expresion  {$$ =resta($1, $3);}
| expresion MULT expresion {$$ =multiplicacion($1, $3);}
| expresion DIV expresion  {$$ = division($1, $3);}
| expresion MOD expresion  {$$ =modulo($1, $3);}
| var_arreglo              {
							expresion *e = new expresion();
							e -> direccion = new_temp();
							e -> tipo = $1 -> exp.tipo;
							cuadrupla *c = new cuadrupla();
							c -> resultado = e -> direccion;
							c -> operacion = SUMA;
							c -> operando1 = std::to_string($1 -> direccion_base);
							c -> operando2 = $1 -> exp.direccion;
							e -> code = concat($1 -> exp.code, *c);
							$$ = e;
							}
| CADENA                   {$$ = get_cadena($1);}
| numeros                  {$$ = get_num($1);}
| ID LPAR parametros RPAR {
	std::map<std::string,funcion>::iterator it_m = tabla_de_funciones.find(*$1);
	if (it_m == tabla_de_funciones.end()){
		//error
	}
	funcion f = it_m -> second;
	if (verif_parametros(f.argumentos, *$3)){
		//error
	}
	expresion *e = new expresion();
	std::vector<std::string> direcs;
	$$ = eval_func(*$3, f);
};

parametros :
/* vacio */ {$$ = new std::vector<expresion>();}
| lista_param {$$ = $1;} ;

lista_param :
lista_param COMA expresion {$$ = $1; (*$$).push_back(*$3);}
| expresion {$$ = new std::vector<expresion>(); (*$$).push_back(*$1);};

condicion :
condicion OR M condicion {
	$$ = new condicion();
	$1->code = backpatch($1->falses, *$3, $1->code);
	$$->trues = merge($1->trues, $4->trues);
	$$->falses = $4->falses;

	$1->t = $$->t;
	$1->f = new_index();
	$4->t = $$->t;
	$4->f = $$->f;
	$$->code = concat(concat(
	                  $1->code,
	                  cuadrupla_label($1->f)),
	                  $4->code);
}
| condicion AND M condicion {
	$$ = new condicion();
	$1->code = backpatch($1->trues, *$3, $1->code);
	$$->trues = $4->trues;
	$$->falses = merge($1->falses, $4->falses);

	$1->t = new_index();
	$1->f = $$->f;
	$4->t = $$->t;
	$4->f = $$->f;
	$$->code = concat(concat(
	                  $1->code,
	                  cuadrupla_label($1->t)),
	                  $4->code);
}
| NOT condicion {
	$$ = new condicion();
	$$->trues = $2->falses;
	$$->falses = $2->trues;

	$2->t = $$->f;
	$2->f = $$->t;
	$$->code = $2->code;
}
| LPAR condicion RPAR {
	$$ = new condicion();
	$$->trues = $2->trues;
	$$->falses = $2->falses;

	$2->t = new_index();
	$2->f = $$->f;
	$$->code = concat($2->code,cuadrupla_label($2->t));
}
| expresion relacional expresion {
	$$ = new condicion();
	std::string i1 = new_index();
	std::string i2 = new_index();
	$$->trues.push_back(i1);
	$$->falses.push_back(i2);

	$$->t = i1;
	$$->f = i2;

	$$ -> code = concat(concat(concat(
	                    $1->code,
	                    $3->code),
	                    cuadrupla_if_rel_goto($1->direccion, $2, $3->direccion, i1)),
	                    cuadrupla_goto(i2));
}
| TRU {
	$$ = new condicion();
	std::string index = new_index();
	$$->t = index;
	$$->trues.push_back(index);
	$$->code.push_back(cuadrupla_goto(index));
}
| FALS {
	$$ = new condicion();
	std::string index = new_index();
	$$->f = index;
	$$->falses.push_back(index);
	$$->code.push_back(cuadrupla_goto(index));
} ;

M :
/* vacío */ { $$ = new std::string("I" + std::to_string(current_index)); } ;

N :
/* vacío */ {
	// Esto basta para construir las estructuras necesarias, lo cuál se hace en la
	// producción IF C S1 ELSE S2
	$$ = new std::string("I" + std::to_string(current_index));
} ;

relacional :
MEN   {$$ = REL_MEN;}
| MAY {$$ = REL_MAY;}
| LEQ {$$ = REL_LEQ;}
| GEQ {$$ = REL_GEQ;}
| DIF {$$ = REL_DIF;}
| EQ  {$$ = REL_EQ;};
%%

expresion *suma(expresion *e1, expresion *e2){
	expresion *e = new expresion();
	cuadrupla *c = new cuadrupla();
	e -> tipo = max(e1 -> tipo, e2 -> tipo);
	if( e -> tipo==-1) yyerror( (char *) "Error de tipos");
	else{
		std::string t = new_temp();
		e -> direccion = t;
		c -> operacion = SUMA;
		c -> operando1 = ampliar(e1 -> direccion, e1 -> tipo, e -> tipo, e);
		c -> operando2 = ampliar(e2 -> direccion, e2 -> tipo, e -> tipo, e);
		c -> resultado = t;
		e->code.push_back(*c);
	}
	return e;
}


expresion *resta(expresion *e1, expresion *e2){
	expresion *e = new expresion();
	cuadrupla *c = new cuadrupla();
	e -> tipo = max(e1 -> tipo, e2 -> tipo);
	if( e -> tipo==-1) yyerror( (char *) "Error de tipos");
	else{
		std::string t = new_temp();
		e -> direccion = t;
		c -> operacion = RESTA;
		c -> operando1 = ampliar(e1 -> direccion, e1 -> tipo, e -> tipo, e);
		c -> operando2 = ampliar(e2 -> direccion, e2 -> tipo, e -> tipo, e);
		c -> resultado = t;
		e->code.push_back(*c);
	}
	return e;
}

expresion *multiplicacion(expresion *e1, expresion *e2){
	expresion *e = new expresion();
	cuadrupla *c = new cuadrupla();
	e -> tipo = max(e1 -> tipo, e2 -> tipo);
	if( e -> tipo==-1) yyerror( (char *) "Error de tipos");
	else{
		std::string t = new_temp();
		e -> direccion = t;
		c -> operacion = MULTIPLICACION;
		c -> operando1 = ampliar(e1 -> direccion, e1 -> tipo, e -> tipo, e);
		c -> operando2 = ampliar(e2 -> direccion, e2 -> tipo, e -> tipo, e);
		c -> resultado = t;
		e->code.push_back(*c);
	}
	return e;
}

expresion *division(expresion *e1, expresion *e2){
	expresion *e = new expresion();
	cuadrupla *c = new cuadrupla();
	e -> tipo = max(e1 -> tipo, e2 -> tipo);
	if( e -> tipo==-1) yyerror( (char *) "Error de tipos");
	else{
		std::string t = new_temp();
		e -> direccion = t;
		c -> operacion = DIVISION;
		c -> operando1 = ampliar(e1 -> direccion, e1 -> tipo, e -> tipo, e);
		c -> operando2 = ampliar(e2 -> direccion, e2 -> tipo, e -> tipo, e);
		c -> resultado = t;
		e->code.push_back(*c);
	}
	return e;
}

expresion *modulo(expresion *e1, expresion *e2){
	expresion *e = new expresion();
	cuadrupla *c = new cuadrupla();
	e -> tipo = max(e1 -> tipo, e2 -> tipo);
	if( e -> tipo==-1) yyerror( (char *) "Error de tipos");
	else{
		std::string t = new_temp();
		e -> direccion = t;
		c -> operacion = MODULO;
		c -> operando1 = ampliar(e1 -> direccion, e1 -> tipo, e -> tipo, e);
		c -> operando2 = ampliar(e2 -> direccion, e2 -> tipo, e -> tipo, e);
		c -> resultado = t;
		e->code.push_back(*c);
	}
	return e;
}

/**
 * Regresa el tipo numerico de mayor precedencia
 **/
int max(int t1, int t2){
	if( t1==t2) return t1;
	if( t1 ==INT && t2 == FLOAT) return FLOAT;
	if( t1 ==FLOAT && t2 == INT) return FLOAT;
	if( t1 ==INT && t2 == DOUB) return DOUB;
	if( t1 ==DOUB && t2 == INT) return DOUB;
	if( t1 ==DOUB && t2 == FLOAT) return DOUB;
	if( t1 ==FLOAT && t2 == DOUB) return DOUB;
	else return -1;
}

/**
 * Extiende un tipo numerico de menor precedencia al de mayor precedencia
 **/
std::string ampliar(std::string dir, int t1, int t2, expresion *e){
	cuadrupla *c = new cuadrupla();
	std::string t = new_temp();
	if( t1==t2) return dir;
	if( t1 ==INT && t2 == FLOAT){
		c -> operacion = AMPLIAR;
		c -> operando1 = "(float)";
		c -> operando2 = dir;
		c -> resultado = t;
		e->code.push_back(*c);
		return t;
	}
	if( t1 ==INT && t2 == DOUB){
		c -> operacion = AMPLIAR;
		c -> operando1 = "(double)";
		c -> operando2 = dir;
		c -> resultado = t;
		e->code.push_back(*c);
		return t;
	}
	if( t1 ==FLOAT && t2 == DOUB) {
		c -> operacion = AMPLIAR;
		c -> operando1 = "(double)";
		c -> operando2 = dir;
		c -> resultado = t;
		e->code.push_back(*c);
		return t;
	}
	return "";
}

/**
 * Reduce un tipo numerico de mayor precedencia al de menor precedencia
 **/
std::string reducir(std::string dir, int t1, int t2, expresion *e){
	cuadrupla *c = new cuadrupla();
	std::string t = new_temp();
	if( t1==t2) return dir;
	if( t1 ==INT && t2 == FLOAT){
		c -> operacion = REDUCIR; //antes EQ;
		c -> operando1 = "(int)";
		c -> operando2 = dir;
		c -> resultado = t;
		e->code.push_back(*c);
		printf("perdida de información se esta asignando un float a un int\n");
		return t;
	}
	if( t1 ==INT && t2 == DOUB){
		c -> operacion = REDUCIR; //antes EQ;
		c -> operando1 = "(int)";
		c -> operando2 = dir;
		c -> resultado = t;
		e->code.push_back(*c);
		printf("perdida de información se esta asignando un double a un int\n");
		return t;
	}
	if( t1 ==FLOAT && t2 == DOUB) {
		c -> operacion = REDUCIR; //antes EQ;
		c -> operando1 = "(float)";
		c -> operando2 = dir;
		c -> resultado = t;
		e->code.push_back(*c);
		printf("perdida de información se esta asignando un double a un float\n");
		return t;
	}
	return "";
}

/**
 * Genera una expresion correspondiente a un numero
 **/
expresion *get_num(numero *n){
	expresion *e = new expresion();
	e -> tipo = n -> tipo;
	e -> direccion = n -> valor;
	return e;
}

/**
 * Obtiene una cadena formando una expresion correspondiente a ella
 **/
expresion *get_cadena(cadena *c) {
	expresion *e = new expresion();
	e -> tipo = c -> tipo;
	e -> direccion = c -> valor;
	return e;
}

expresion *identificador(std::string id){
	expresion *e = new expresion();
	if(var_esta_definida(id) != -1) {
		e -> tipo = get_tipo_simbolo(id).tipo;
		e -> direccion = get_direccion_simbolo(id);
	} else {
		yyerror( (char *) "Error semantico: el identificador no existe");
	}
	return e;
}

/**
 * Funcion auxiliar para verificar que los tipos de los parametros corresponden con
 * los argumentos
 **/
bool verif_parametros(std::vector<simbolo> argu, std::vector<expresion> params) {
	if (argu.size() != params.size()) 
		return false;
	//std::vector<simbolo>::iterator it_s = argu.begin();
	std::vector<expresion>::iterator it_v = params.begin();
	for (int i = 0; i < argu.size(); i++) {
		if(argu[i].t.tipo != params[i].tipo)
			return false;
	}
	return true;
}

/**
 * Genera una expresion correspondiente a la evaluacion de una funcion
 **/
expresion *eval_func(std::vector<expresion> params, funcion f) {
	expresion *e = new expresion();
	std::vector<std::string> direcs;
	expresion tmp;
	for (int i = 0; i < params.size(); i++) {
		tmp = params[i];
		e -> code = concat(e -> code, tmp.code);
		direcs.push_back(tmp.direccion);
	}
	for (int j = 0; j < direcs.size(); j++)
		e -> code = concat(e -> code, cuadrupla_param(direcs[j]));
	// aqui falta definir bien
	e -> code = concat(e -> code, cuadrupla_call(f.etiqueta));
	e -> tipo = f.tipo_r;
	e -> direccion = new_temp();
	return e;
}

/**
 * Obtiene el tamano en bytes de un tipo basico
 **/
int obtener_tam_basico(int tipo) {
	if (tipo == INT || tipo == FLOAT)
		return 4;
	if (tipo == DOUB)
		return 8;
	if (tipo == CHAR)
		return 1;
	return -1;
}

/**
 * Verifica si una variable esta definida en el ambiente local o en el ambiente general
 * Regresa el indici en la tabla correspondiente al simbolo y -1 en caso de que no este definida
 **/
int var_esta_definida(std::string id) {
	if (tabla_de_simbolos.busca(id) != -1)
		return tabla_de_simbolos.busca(id);
	else if (respaldo_tabla_simbolos != NULL && (*respaldo_tabla_simbolos).busca(id) != -1)
		return (*respaldo_tabla_simbolos).busca(id);
	return -1;
}

/**
 * Obtiene la direccion de un simbolo definido en la tabla global o local
 * Si no esta definida regresa -1
 **/
int get_direccion_simbolo(std::string id) {
	if (tabla_de_simbolos.busca(id) != -1)
		return tabla_de_simbolos.get_direccion(id);
	else if (respaldo_tabla_simbolos != NULL && (*respaldo_tabla_simbolos).busca(id) != -1)
		return (*respaldo_tabla_simbolos).get_direccion(id);
	return -1;
}

/**
 * Obtiene el tipo de un simbolo definido en la tabla global o local
 * Si no existe regresa un tipo vacio
 **/
tipo get_tipo_simbolo(std::string id) {
	tipo regreso = *(new tipo());
	if (tabla_de_simbolos.busca(id) != -1)
		regreso = tabla_de_simbolos.get_tipo(id);
	else if (respaldo_tabla_simbolos != NULL && (*respaldo_tabla_simbolos).busca(id) != -1) {
		regreso = (*respaldo_tabla_simbolos).get_tipo(id);
	}
	return regreso;
}

sentencia* crea_sentencia() {
	sentencia* s = new sentencia();
	s->next = new_label();
	return s;
}

void yyerror(char *msg) {
	std::cout << "ERROR: " << msg << " on line " << yylineno << std::endl;
	exit(1);
}

std::string new_label() { return "L" + std::to_string(current_label++); }
std::string new_func_label() { return "F" + std::to_string(current_func_label++); }
std::string new_index() { return "I" + std::to_string(current_index++); }
std::string new_temp()  { return "T" + std::to_string(current_temp++); }
void qprint(std::string s) { std::cout << s << std::endl; }

template<typename Type>
std::vector<Type> concat(std::vector<Type> v1, std::vector<Type> v2) {
	v1.insert( v1.end(), v2.begin(), v2.end() );
	return v1;
}

template<typename Type>
std::vector<Type> concat(std::vector<Type> v, Type elem) {
	v.push_back(elem);
	return v;
}

template<typename Type>
std::vector<Type> concat(Type elem, std::vector<Type> v) {
	return concat(std::vector<Type>(1,elem),v);
}
