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
