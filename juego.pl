:- [hechos].
:- [logica].

% ====== Juego principal ======
% Entradas: Ninguna
% Salidas: Inicia el juego mostrando el estado inicial
% Restricciones: Ninguna
jugar :-
    nl, write("=== Juego de Aventura ==="), nl,
    mostrar_estado,
    repetir.

% ====== Ciclo principal del juego ======
% Entradas: Opcion del usuario via read
% Salidas: Ejecuta la accion correspondiente y repite hasta salir
% Restricciones: Ninguna
repetir :-
    write("> "),
    read(Opcion),
    ejecutar_opcion(Opcion),
    (Opcion == 11 -> write("Gracias por jugar."), nl ;
     mostrar_estado,
     repetir).


% ====== Ejecutar comandos ======
% Entradas: Comando a ejecutar
% Salidas: Resultado del comando
% Restricciones: El comando debe ser valido
ejecutar(Comando) :-
    call(Comando), !.
ejecutar(_) :-
    write("Comando no reconocido."), nl.

% ====== Mostrar estado actual ======
% Entradas: Ninguna
% Salidas: Muestra ubicacion actual y opciones disponibles
% Restricciones: Ninguna
mostrar_estado :-
    nl,
    descripcion_actual,
    verificar_objeto_en_lugar,
    mostrar_opciones,
    nl.

% ====== Descripcion del lugar actual ======
% Entradas: Ninguna
% Salidas: Nombre y descripcion del lugar donde esta el jugador
% Restricciones: Ninguna
descripcion_actual :-
    jugador(Lugar),
    lugar(Lugar, Desc),
    format("Estas en ~w.~n~w~n", [Lugar, Desc]).

% ====== Verificar si hay objeto en el lugar ======
% Entradas: Ninguna
% Salidas: Mensaje si encuentra un objeto nuevo en el lugar
% Restricciones: El objeto no debe estar ya en el inventario
verificar_objeto_en_lugar :-
    jugador(Lugar),
    objeto(Objeto, Lugar),
    inventario(Inv),
    \+ member(Objeto, Inv),
    format("¡¡Encontraste ~w!!~n", [Objeto]), !.
verificar_objeto_en_lugar.

% ====== Mostrar comandos disponibles ======
% Entradas: Ninguna
% Salidas: Menu de opciones del juego
% Restricciones: Ninguna
mostrar_opciones :-
    nl, write("Opciones disponibles:"), nl,
    write("  1. tomar objeto.                  7. lugares visitados."), nl,
    write("  2. usar objeto.                   8. ruta(Inicio, Fin, Camino)."), nl,
    write("  3. puedo ir (lugar).              9. como gano."), nl,
    write("  4. moverme (lugar).               10. verificar gane."), nl,
    write("  5. donde esta objeto.             11. salir."), nl,
    write("  6. inventario.                  "), nl.


% ====== Manejador de opciones numericas ======
% Entradas: Numero de opcion del 1 al 11
% Salidas: Ejecuta la accion correspondiente a la opcion
% Restricciones: La opcion debe ser un numero valido del 1 al 11
ejecutar_opcion(1) :- tomar, !.
ejecutar_opcion(2) :-
    mostrar_objetos_sin_usar,
    write("Que objeto deseas usar? "),
    read(Objeto),
    usar(Objeto), !.
ejecutar_opcion(3) :-
    puedo_ir, !.
ejecutar_opcion(4) :-
    write("A que lugar deseas moverte? "),
    read(Lugar),
    mover(Lugar), !.
ejecutar_opcion(5) :-
    donde_esta, !.
ejecutar_opcion(6) :-
    mostrar_inventario,
    mostrar_opciones,
    !.
ejecutar_opcion(7) :-
    lugares_visitados, !.
ejecutar_opcion(8) :- write("Funcion 'ruta' aun no implementada."), nl, !.
ejecutar_opcion(9) :- write("Funcion 'como_gano' aun no implementada."), nl, !.
ejecutar_opcion(10) :- write("Funcion 'verifica_gane' aun no implementada."), nl, !.
ejecutar_opcion(11) :- !.  % salir
ejecutar_opcion(_) :-
    write("Opcion no valida. Intente de nuevo."), nl.

ejecutar_opcion(8) :-
    write("Ruta desde: "), read(Inicio),
    write("hasta: "), read(Fin),
    ruta(Inicio, Fin, Camino),
    format("Ruta encontrada: ~w~n", [Camino]), !.

ejecutar_opcion(9) :-
    como_gano, !.

ejecutar_opcion(10) :-
    verifica_gane, !.

ejecutar_opcion(11) :-
    write("Gracias por jugar."), nl, halt.

ejecutar_opcion(_) :-
    write("Opcion no valida. Intenta de nuevo."), nl.


