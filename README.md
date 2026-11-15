# APNEE AS Gleam

Pour ce prototype, j'ai implémenté un tokenizer et un lexer simplistes, et me suis limité à calculer la premiere expression seulement (avant le premier `;`).

J'utiliser un `case` pour pattern match sur la valeur du terminal et du non-terminal.

N'ayant pas acces à des variables globales (en tous cas pas directement), les résultats des calculs sont passés par argument, et sont optionnels.

Si c'était à refaire je m'y prendrait très différament.

Je n'ai implémenté que certaines règles pour éviter de perdre du temps ; le but était juste de comprendre la logique du problème.