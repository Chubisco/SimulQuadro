# SimulQuadro
Simulação de uma aplicação P2P - utilizando o protocolo Freechains - para "administrar" quadros de aviso públicos; Definir que postagens devem ocupar o espaço limitado do quadro de avisos.

# A. Introdução
  Minha ideia seria "ranquear" as postagens baseado no seu tema, na sua urgência, na sua recência e também na sua popularidade para decidir quanto "tempo de tela" ou "espaço de tela" cada postagem teria baseado nesse ranking.

  As postagens serão feitas em arquivos .json, formatadas de forma que a aplicação possa identificar o tema da publicação ("Finanças", "Comemorações", "Reclamações", etc) e, caso a postagem seja sobre um evento que ainda está para acontecer, uma data futura (opcional).
  Ao fazer uma publicação, a aplicação dá uma quantidade de pontos (de 1-5) para o post baseado em seu tema, temas importantes como Finanças, recebem 5 pontos; enquanto posts sobre uma festa, com o tema "Comemorações" receberiam apenas 1 ponto.
  Paralelamente, a cada 30 minutos, a aplicação irá buscar as 3 postagens mais populares, ou seja, com mais likes no protocolo Freechains, e vai atribuir pontos à elas; 3 para a publicação com mais likes, 2 para a segunda colocada e 1 ponto para a terceira. Esses pontos são redistribuídos a cada 30 minutos.
  Além disso, será possível referenciar uma data futura em sua publicação, definindo quando um evento vai acontecer; Com essa informação, a aplicação irá calcular a diferença entre a data em que a postagem foi feita e a data futura referenciada na postagem e, conforme a data futura se aproxima, a postagem recebe esses “pontos de urgência”, até o máximo de 5. Esses pontos são perdidos após a data futura referenciada.
  Simultaneamente, para evitar que postagens feitas muito próximas uma da outra se “apaguem”, toda postagem ganha 2 pontos durante sua primeira hora na cadeia; Caso a postagem mais atual da cadeia tenha sido feita à menos de 1hr, deixamos a nova postagem em uma "fila" até esse período acabar, depois disso, esses 2 pontos passam para a nova postagem e assim por diante.

  Por fim, a aplicação fica constantemente monitorando a pontuação das postagens, garantindo que apenas as postagens consideradas mais relevantes (com maior pontuação), sejam apresentadas no nosso quadro de avisos.

# B. O que foi implementado
- Uma breve simulação do que a aplicação propõe, caminhar por toda a cadeia e avaliar cada postagem com base em seu tema, na sua urgência, na sua recência e também na sua popularidade;
- Um fórum com postagens em .json aleatórias apenas para teste;
- Mensagens de debug para identificar falhas e facilitar a continuação do desenvolvimento da aplicação.
  
# C. O que não foi implementado
- Uma interface com a qual o usuário possa interagir, atualmente é apenas uma simulação que pode ser rodada no prompt de comando;
- Melhor uso dos arquivos json; o "tempo" dos posts - usado no cálculo de urgência e recência - ainda é contado a partir do relógio da maquina;

# D. Ferramentas usadas
- Freechains

# E. Conclusão
A simulação funcionou como o esperado, apesar de não demonstrar o potencial idealizado da aplicação, é possível manipular as postagens e verificar que o sistema de ranking funciona relativamente bem.
