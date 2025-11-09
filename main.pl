% ======= Archivo principal del juego =======
% Carga todos los modulos necesarios para el juego
:- consult('hechos.pl').
:- consult('estado.pl').
:- consult('logica.pl').
:- consult('juego.pl').

% ======= Iniciar el juego =======
% Entradas: Ninguna
% Salidas: Inicia el juego de aventura
% Restricciones: Ninguna
inicio :-
    jugar.
