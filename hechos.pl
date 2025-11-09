% ======= Lugares =======
% Define los lugares del juego con su nombre y descripcion
% Formato: lugar(Nombre, Descripcion)
lugar(bosque, "Bosque sombrio con arboles milenarios.").
lugar(puente, "Un viejo puente de madera.").
lugar(cueva, "Cueva donde habita el dragon.").
lugar(templo, "Templo abandonado con inscripciones antiguas.").

% ======= Conexiones =======
% Define las conexiones directas entre lugares
% Formato: conectado(LugarOrigen, LugarDestino)
conectado(bosque, puente).
conectado(puente, cueva).
conectado(bosque, templo).

% ======= Objetos =======
% Define los objetos y su ubicacion inicial
% Formato: objeto(NombreObjeto, LugarInicial)
objeto(llave, templo).
objeto(espada, bosque).
objeto(escudo, puente).

% ======= Requisitos =======
% Define que objeto se requiere para acceder a un lugar
% Formato: requiere(ObjetoRequerido, LugarDestino)
requiere(llave, cueva).
requiere(espada, puente).
requiereVisita(cueva, bosque).

% ======= Tesoro =======
% Define donde se encuentran los tesoros
% Formato: tesoro(Lugar, Objeto)
tesoro(templo, escudo).
