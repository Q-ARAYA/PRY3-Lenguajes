% ====== Tomar el objeto del lugar actual ======
% Entradas: Ninguna
% Salidas: Mensaje indicando si se tomo el objeto o no
% Restricciones: El objeto debe estar en el lugar actual y no estar ya en el inventario
tomar :-
    jugador(Lugar),
    objeto(Objeto, Lugar),
    inventario(Inv),
    \+ member(Objeto, Inv),
    retract(inventario(Inv)),
    assert(inventario([Objeto|Inv])),
    format("Has tomado el objeto: ~w.~n", [Objeto]), !.

tomar :-
    jugador(Lugar),
    \+ objeto(_, Lugar),
    write("No hay ningun objeto en este lugar."), nl, !.

tomar :-
    jugador(Lugar),
    objeto(Objeto, Lugar),
    inventario(Inv),
    member(Objeto, Inv),
    write("Ya tienes este objeto."), nl, !.

% ====== Mostrar inventario ======
% Entradas: Ninguna
% Salidas: Lista de objetos en el inventario o mensaje si esta vacio
% Restricciones: Ninguna
mostrar_inventario :-
    inventario(Inv),
    (Inv = [] ->
        write("No tienes objetos en tu inventario."), nl
    ;
        write("Inventario actual: "), write(Inv), nl).

% ====== Mostrar objetos sin usar ======
% Entradas: Ninguna
% Salidas: Lista de objetos disponibles indicando cuales ya fueron usados
% Restricciones: Ninguna
mostrar_objetos_sin_usar :-
    inventario(Inv),
    (Inv = [] ->
        write("No tienes objetos en tu inventario."), nl
    ;
        write("Objetos disponibles para usar:"), nl,
        mostrar_lista_sin_usar(Inv)
    ).

% ====== Auxiliar para mostrar lista de objetos ======
% Entradas: Lista de objetos
% Salidas: Cada objeto con su estado de uso
% Restricciones: Ninguna
mostrar_lista_sin_usar([]).
mostrar_lista_sin_usar([Obj|Resto]) :-
    usados(ListaUsados),
    (member(Obj, ListaUsados) ->
        format("  - ~w (ya usado)~n", [Obj])
    ;
        format("  - ~w~n", [Obj])
    ),
    mostrar_lista_sin_usar(Resto).

% ====== Usar objeto ======
% Entradas: Objeto a usar
% Salidas: Mensaje indicando si se uso el objeto o no
% Restricciones: El objeto debe estar en el inventario y no haber sido usado previamente
usar(Objeto) :-
    inventario(Inv),
    member(Objeto, Inv),
    usados(ListaUsados),
    \+ member(Objeto, ListaUsados),
    retract(usados(ListaUsados)),
    assert(usados([Objeto|ListaUsados])),
    format("Has usado el objeto: ~w. Ahora puedes acceder a nuevos lugares.~n", [Objeto]), !.

usar(Objeto) :-
    inventario(Inv),
    \+ member(Objeto, Inv),
    format("No tienes ~w en tu inventario.~n", [Objeto]), !.

usar(Objeto) :-
    usados(ListaUsados),
    member(Objeto, ListaUsados),
    format("Ya has usado ~w anteriormente.~n", [Objeto]), !.

% ====== Mostrar todos los lugares y su estado de acceso ======
% Entradas: Ninguna
% Salidas: Lista de todos los lugares con su estado de accesibilidad
% Restricciones: Ninguna
puedo_ir :-
    jugador(Actual),
    write("Lugares disponibles desde tu ubicacion actual:"), nl,
    findall(L, lugar(L, _), Lugares),
    mostrar_estado_lugares(Lugares, Actual).

% ====== Auxiliar para mostrar estado de cada lugar ======
% Entradas: Lista de lugares y lugar actual
% Salidas: Estado de cada lugar indicando si es accesible o bloqueado
% Restricciones: Ninguna
mostrar_estado_lugares([], _).
mostrar_estado_lugares([Lugar|Resto], Actual) :-
    (Lugar == Actual ->
        format("  - ~w (ubicacion actual)~n", [Lugar])
    ; (conectado(Actual, Lugar) ; conectado(Lugar, Actual)) ->
        % Hay conexión, verificar si está bloqueado
        (requiere(ObjetoRequerido, Lugar) ->
            usados(ListaUsados),
            (member(ObjetoRequerido, ListaUsados) ->
                format("  - ~w (accesible)~n", [Lugar])
            ;
                format("  - ~w (bloqueado - requiere ~w)~n", [Lugar, ObjetoRequerido])
            )
        ;
            format("  - ~w (accesible)~n", [Lugar])
        )
    ;
        format("  - ~w (sin conexion directa)~n", [Lugar])
    ),
    mostrar_estado_lugares(Resto, Actual).

% ====== Mover al jugador a un nuevo lugar ======
% Entradas: Lugar destino
% Salidas: Mensaje indicando si se movio o no
% Restricciones: Debe existir conexion directa y si el lugar requiere objeto debe estar usado
mover(Lugar) :-
    jugador(Actual),
    (Actual == Lugar ->
        write("Ya estas en ese lugar."), nl, !
    ; true),
    % Verificar conexión directa (bidireccional)
    (conectado(Actual, Lugar) ; conectado(Lugar, Actual)),
    % Verificar si el lugar requiere algún objeto
    (requiere(ObjetoRequerido, Lugar) ->
        usados(ListaUsados),
        (member(ObjetoRequerido, ListaUsados) ->
            % Mover al jugador
            retract(jugador(Actual)),
            assert(jugador(Lugar)),
            % Registrar lugar como visitado si no lo estaba
            (visitado(Lugar) -> true ; assert(visitado(Lugar))),
            format("Te has movido a ~w.~n", [Lugar])
        ;
            format("No puedes ir a ~w. Necesitas usar ~w primero.~n", [Lugar, ObjetoRequerido]),
            fail
        )
    ;
        % No requiere objeto, mover directamente
        retract(jugador(Actual)),
        assert(jugador(Lugar)),
        % Registrar lugar como visitado si no lo estaba
        (visitado(Lugar) -> true ; assert(visitado(Lugar))),
        format("Te has movido a ~w.~n", [Lugar])
    ), !.

mover(Lugar) :-
    jugador(Actual),
    \+ conectado(Actual, Lugar),
    \+ conectado(Lugar, Actual),
    format("No hay un camino directo desde ~w hacia ~w.~n", [Actual, Lugar]), !.

% ====== Mostrar donde estan todos los objetos ======
% Entradas: Ninguna
% Salidas: Lista de todos los objetos con su ubicacion y estado
% Restricciones: Ninguna
donde_esta :-
    write("Ubicacion de objetos:"), nl,
    findall(Obj-Lugar, objeto(Obj, Lugar), Objetos),
    mostrar_ubicacion_objetos(Objetos).

% ====== Auxiliar para mostrar ubicacion de cada objeto ======
% Entradas: Lista de objetos con su ubicacion
% Salidas: Muestra cada objeto indicando si esta en inventario o no
% Restricciones: Ninguna
mostrar_ubicacion_objetos([]).
mostrar_ubicacion_objetos([Obj-Lugar|Resto]) :-
    inventario(Inv),
    (member(Obj, Inv) ->
        format("  - ~w se encuentra en ~w (encontrado)~n", [Obj, Lugar])
    ;
        format("  - ~w se encuentra en ~w (no encontrado)~n", [Obj, Lugar])
    ),
    mostrar_ubicacion_objetos(Resto).

% ====== Mostrar lugares visitados ======
% Entradas: Ninguna
% Salidas: Lista de todos los lugares que el jugador ha visitado
% Restricciones: Ninguna
lugares_visitados :-
    write("Lugares visitados:"), nl,
    findall(L, visitado(L), Lugares),
    mostrar_lista_lugares(Lugares).

% ====== Auxiliar para mostrar lista de lugares ======
% Entradas: Lista de lugares
% Salidas: Imprime cada lugar visitado
% Restricciones: Ninguna
mostrar_lista_lugares([]).
mostrar_lista_lugares([Lugar|Resto]) :-
    format("  - ~w~n", [Lugar]),
    mostrar_lista_lugares(Resto).

% ====== Encontrar ruta entre dos lugares ======
% Entradas: Lugar de inicio y lugar de destino
% Salidas: Camino como lista de lugares desde Inicio hasta Fin
% Restricciones: Debe existir una conexion directa o indirecta entre los lugares
ruta(Inicio, Fin, Camino) :-
    ruta_aux(Inicio, Fin, [Inicio], CaminoReverso),
    reverse(CaminoReverso, Camino).

% ====== Auxiliar para buscar ruta con backtracking ======
% Entradas: Lugar actual, destino y lugares visitados en esta busqueda
% Salidas: Camino encontrado en orden reverso
% Restricciones: No revisitar lugares ya explorados en esta ruta
ruta_aux(Actual, Actual, Visitados, Visitados).
ruta_aux(Actual, Destino, Visitados, Camino) :-
    (conectado(Actual, Siguiente) ; conectado(Siguiente, Actual)),
    \+ member(Siguiente, Visitados),
    ruta_aux(Siguiente, Destino, [Siguiente|Visitados], Camino).

% ====== Mostrar como ganar el juego ======
% Entradas: Ninguna
% Salidas: Rutas posibles para llegar a cada tesoro con los requisitos
% Restricciones: Ninguna
como_gano :-
    jugador(Actual),
    write("Formas de ganar desde tu ubicacion actual:"), nl, nl,
    findall(Lugar-Tesoro, tesoro(Lugar, Tesoro), Tesoros),
    (Tesoros = [] ->
        write("No hay tesoros definidos en el juego."), nl
    ;
        mostrar_rutas_tesoros(Tesoros, Actual)
    ).

% ====== Auxiliar para mostrar rutas a cada tesoro ======
% Entradas: Lista de tesoros y ubicacion actual
% Salidas: Imprime ruta y requisitos para cada tesoro
% Restricciones: Ninguna
mostrar_rutas_tesoros([], _).
mostrar_rutas_tesoros([Lugar-Tesoro|Resto], Actual) :-
    format("Tesoro: ~w en ~w~n", [Tesoro, Lugar]),
    (ruta(Actual, Lugar, Camino) ->
        format("  Ruta: ~w~n", [Camino]),
        mostrar_requisitos_ruta(Camino),
        format("  Condicion final: Llegar a ~w y obtener ~w~n", [Lugar, Tesoro])
    ;
        write("  No hay ruta disponible desde tu ubicacion actual."), nl
    ),
    nl,
    mostrar_rutas_tesoros(Resto, Actual).

% ====== Mostrar requisitos para una ruta ======
% Entradas: Lista de lugares que forman la ruta
% Salidas: Objetos requeridos para cada lugar
% Restricciones: Ninguna
mostrar_requisitos_ruta([]).
mostrar_requisitos_ruta([_]).
mostrar_requisitos_ruta([_|[Siguiente|Resto]]) :-
    (requiere(Objeto, Siguiente) ->
        format("  - Para ir a ~w necesitas: ~w (debe estar usado)~n", [Siguiente, Objeto])
    ;
        true
    ),
    mostrar_requisitos_ruta([Siguiente|Resto]).

% ====== Verificar si el jugador ha ganado ======
% Entradas: Ninguna
% Salidas: Indica si gano mostrando camino inventario y condicion de victoria
% Restricciones: Debe estar en el lugar del tesoro y tener el objeto en inventario
verifica_gane :-
    jugador(LugarActual),
    inventario(Inv),
    tesoro(LugarActual, Tesoro),
    member(Tesoro, Inv),
    write("========================================"), nl,
    write("     FELICIDADES HAS GANADO EL JUEGO"), nl,
    write("========================================"), nl, nl,
    write("Camino realizado:"), nl,
    findall(L, visitado(L), Lugares),
    format("  ~w~n", [Lugares]), nl,
    write("Inventario de objetos:"), nl,
    format("  ~w~n", [Inv]), nl,
    write("Condicion de victoria cumplida:"), nl,
    format("  - Estas en ~w~n", [LugarActual]),
    format("  - Tienes el tesoro: ~w~n", [Tesoro]), nl,
    write("========================================"), nl, !.

verifica_gane :-
    jugador(LugarActual),
    inventario(Inv),
    write("Aun no has ganado el juego."), nl, nl,
    (tesoro(_, _) ->
        write("Condiciones para ganar:"), nl,
        findall(Lugar-Tesoro, tesoro(Lugar, Tesoro), Tesoros),
        verificar_condiciones_tesoros(Tesoros, LugarActual, Inv)
    ;
        write("No hay condiciones de victoria definidas."), nl
    ).

% ====== Auxiliar para verificar cada condicion de tesoro ======
% Entradas: Lista de tesoros lugar actual e inventario
% Salidas: Estado de cada condicion de victoria
% Restricciones: Ninguna
verificar_condiciones_tesoros([], _, _).
verificar_condiciones_tesoros([Lugar-Tesoro|Resto], LugarActual, Inv) :-
    format("  Tesoro ~w en ~w:~n", [Tesoro, Lugar]),
    (LugarActual == Lugar ->
        write("    [OK] Estas en el lugar correcto~n")
    ;
        format("    [X] Necesitas estar en ~w (actualmente en ~w)~n", [Lugar, LugarActual])
    ),
    (member(Tesoro, Inv) ->
        write("    [OK] Tienes el tesoro~n")
    ;
        format("    [X] Necesitas tener ~w en tu inventario~n", [Tesoro])
    ),
    verificar_condiciones_tesoros(Resto, LugarActual, Inv).
