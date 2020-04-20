:- begin_tests(typeInf).
:- include(typeInf). 

/* Note: when writing tests keep in mind that 
    the use of of global variable and function definitions
    define facts for gvar() predicate. Either test
    directy infer() predicate or call
    delegeGVars() predicate to clean up gvar().
*/

% tests for typeExp
test(typeExp_add) :-
    typeExp(+(int,int), int).

test(typeExp_add_F, [fail]) :- 
    typeExp(+(int, int), float).

% Should fail
test(typeExp_add_F, [fail]) :- 
    typeExp(+(int, int), float).

test(typeExp_add_F2, [fail]) :-
    typeExp(+(float, float), int).

test(typeExp_sub) :- 
    typeExp(-(int, int), int). 

% Should fail
test(typeExp_sub_F, [fail]) :- 
    typeExp(-(int, int), float).

test(typeExp_sub_F2, [fail]) :-
    typeExp(-(float, float), int).

test(typeExp_mult) :-
    typeExp(*(int, int), int). 

% Should fail
test(typeExp_mult_F, [fail]) :- 
    typeExp(*(int, int), float).

test(typeExp_mult_F2, [fail]) :-
    typeExp(*(float, float), int).

test(typeExp_div) :-
    typeExp(/(int,int), int).

% Should fail
test(typeExp_div_F, [fail]) :- 
    typeExp(/(int, int), float).

test(typeExp_div_F2, [fail]) :-
    typeExp(/(float, float), int).

test(typeExp_fToInt) :-
    typeExp(fToInt(float), int).

test(typeExp_fToInt, [fail]) :-
    typeExp(fToInt(float), float).

test(typeExp_itToFloat) :- 
    typeExp(iToFloat(int), float). 

test(typeExp_itToFloat, [fail]) :- 
    typeExp(iToFloat(int), int).

test(typeExp_typeInt, [nondet]) :- 
    typeExp(3, int). 

test(typeExp_typeInt_F, [fail]) :- 
    typeExp(3, float). 

test(typeExp_typeFloat, [nondet]) :- 
    typeExp(3.2, float).

test(typeExp_typeFloat, [fail]) :- 
    typeExp(3.2, int).

test(typeBoolExp) :-
    true.

test(typeBoolExp, [fail]) :- 
    false.

test(typeExp_bool_1, [nondet, true]) :- 
    typeBoolExp(2 < 3).

test(typeExp_bool_1, [nondet, true]) :- 
    typeBoolExp(-2 < 3).

test(typeExp_bool_2, [nondet, true]) :-
    typeBoolExp(3 > 2).

test(typeExp_bool_2, [nondet, true]) :-
    typeBoolExp(-3 > -4).

test(typeExp_bool_3, [nondet, true]) :-
    typeBoolExp(3 == 3).

test(typeBoolExp_bool_4, [nondet, true]) :- 
    typeBoolExp(3 =< 3).

test(typeBoolExp_bool_5, [nondet, true]) :- 
    typeBoolExp(3 =< 5).

test(typeBoolExp_bool_div, [nondet, true]) :- 
    typeBoolExp(4 \== 2).


% this test should fail
test(typeExp_iplus_F, [fail]) :-
    typeExp(iplus(int, int), float).

/*test(typeExp_iplus_T, [true(T == int)]) :-
    typeExp(iplus(int, int), T).*/


% NOTE: use nondet as option to test if the test is nondeterministic

% test for statement with state cleaning
test(typeStatement_gvar, [nondet, true(T == float)]) :- % should succeed with T=int
    deleteGVars(), /* clean up variables */
    typeStatement(gvLet(v, T, 1.2+3.4), unit),
    gvar(v, float). % make sure the global variable is defined

% same test as above but with infer 
test(infer_gvar, [nondet]) :-
    infer([gvLet(v, T, 2+3)], unit),
    assertion(T==int),
    gvar(v,int).

% either float or int
test(infer_gfunc, [nondet]) :-
    infer([gfLet(hi, [a,b], [a+b])], [T|Ts]),
    assertion([T|Ts]==[T,T,T]),
    gvar(hi,[T,T,T]).

test(infer_gvlet_exp_gflet_func_letin, [nondet]) :-
    infer([gvLet(mult, T2, 2+7),exp(mult + 9) ,gfLet(hi, [a,b], [for(i, 2, 5, [letin(c, T3, 2+5, [exp(a+b)])])]), exp(9 < 3), hi(2,mult), letin(a, T1, hi(9,mult), [exp(a+6)])], T),
    assertion(T2==int),
    gvar(mult, int),
    assertion(T3==int),
    gvar(hi, [int,int,int]),
    assertion(T1==int),
    assertion(T==int).

test(infer_gflet_float, [nondet]) :-
    infer([gfLet(hi, [a,b], [for(i, 2, 5, [exp(a+b)])]), exp(9 < 3), hi(2.2,5.6)], T),
    gvar(hi, [float,float,float]),
    assertion(T==float).

test(infer_letin_if, [nondet]) :-
    infer([letin(a, T1, 2 < 3, [if(a, [exp(2+9)], [letin(b, T2, 2-9, [exp(b*7)])])])],T),
    assertion(T1 == bool),
    assertion(T2 == int),
    assertion(T == int).

test(infer_multGvLet, [nondet]) :-
    infer([gvLet(b, T1, true),gvLet(y, T2, 5+6), gvLet(x, T3, 7+y), gvLet(z, T4, 6.9+0.9), for(i, y, x, [exp(x+y), letin(f, T5, 7.8/5.6, [exp(f*z), exp(f < 7.8), exp(z =< f)])])],T),
    assertion(T1 == bool),
    gvar(b, bool),
    assertion(T2 == int),
    gvar(y, int),
    assertion(T3 == int),
    gvar(x, int),
    assertion(T4 == float),
    gvar(z, float),
    assertion(T5 == float),
    assertion(T == bool).

test(infer_if_for_print, [nondet]) :-
    infer([if(5 \== 7, [print('hi')] , [for(i, 5, 10, [print('bye')])])],T),
    assertion(T == unit).

test(infer_functionWithinFunction, [nondet]) :-
    infer([gfLet(hi, [a,b], [for(i, 2, 5, [letin(c, T1, 2+5, [exp(a<b)])])]), gfLet(bye, [x,y], [if(x ; y, [hi(3,4)], [hi(7,8)])]), bye(false, true)],T),
    assertion(T1 == int),
    gvar(hi, [int, int, bool]),
    gvar(bye, [bool, bool, bool]),
    assertion(T == bool).

test(infer_for_function, [nondet]) :-
    infer([gfLet(hi, [a,b], [letin(c, T1, a+b, [exp(1+c)])]), for(i, hi(3,4), hi(9,10), [exp(i * hi(i,9))])], T),
    assertion(T1 == int),
    gvar(hi, [int, int, int]),
    assertion(T == int).

test(infer_globalVarPassIntoFunction, [nondet]) :-
    infer([gvLet(b, T1, true), gvLet(a, T2, 5 =< 9), gfLet(hi, [a,b], [letin(c, T3, (b ; a), [exp(not(c))])]), hi(a, b)],T),
    assertion(T1 == bool),
    gvar(b, bool),
    assertion(T2 == bool),
    gvar(a, bool),
    assertion(T3 == bool),
    gvar(hi, [bool, bool, bool]),
    assertion(T == bool).



% test custom function with mocked definition
test(mockedFct, [nondet]) :-
    deleteGVars(), % clean up variables since we cannot use infer
    asserta(gvar(my_fct, [int, float])), % add my_fct(int)-> float to the gloval variables
    typeExp(my_fct(X), T), % infer type of expression using or function
    assertion(X==int), assertion(T==float). % make sure the types infered are correct

:-end_tests(typeInf).
