#!/bin/bash

#set -x

# --- RESET DE HOSTS ---
echo "🔄 Encerrando processos freechains-host nas portas 8551, 8552 e 8553..."

# Encontra e mata os processos que usam as portas
for PORT in 8551 8552 8553; do
    PID=$(lsof -t -i:$PORT)
    if [ -n "$PID" ]; then
        echo "⚠️  Matando processo na porta $PORT (PID=$PID)"
        kill -9 $PID
    else
        echo "✅ Nenhum processo ativo na porta $PORT"
    fi
done

echo ""
echo "🧹 Limpando diretórios dos hosts em /tmp..."

for DIR in /tmp/myhost1 /tmp/myhost2 /tmp/myhost3; do
    if [ -d "$DIR" ]; then
        echo "🗑️  Removendo $DIR"
        rm -rf "$DIR"
    else
        echo "✅ Diretório $DIR já está limpo"
    fi
done

echo "✅ Ambiente limpo! Pode reiniciar os hosts com segurança."

# Inicia 3 hosts em portas distintas
freechains-host start /tmp/myhost1 --port=8551 &	# & é pra rodar em segundo plano
freechains-host start /tmp/myhost2 --port=8552 &
freechains-host start /tmp/myhost3 --port=8553 &

sleep 2		# espera 2 segundos antes de continuar

# Criação das chaves para cada usuário
CHAVES=$(freechains keys pubpvt "pioneiro1" --port=8551) #Jorge
PUB1=$(echo "$CHAVES" | cut -d' ' -f1)
PVT1=$(echo "$CHAVES" | cut -d' ' -f2)

CHAVES=$(freechains keys pubpvt "pioneiro2" --port=8551) #Matheus
PUB2=$(echo "$CHAVES" | cut -d' ' -f1)
PVT2=$(echo "$CHAVES" | cut -d' ' -f2)

CHAVES=$(freechains keys pubpvt "noob" --port=8552) #Gabriela
PUBNoob=$(echo "$CHAVES" | cut -d' ' -f1)
PVTNoob=$(echo "$CHAVES" | cut -d' ' -f2)

CHAVES=$(freechains keys pubpvt "userativo" --port=8552) #Francisco
PUBAtivo=$(echo "$CHAVES" | cut -d' ' -f1)
PVTAtivo=$(echo "$CHAVES" | cut -d' ' -f2)

CHAVES=$(freechains keys pubpvt "troll" --port=8553) #Rafa
PUBTroll=$(echo "$CHAVES" | cut -d' ' -f1)
PVTTroll=$(echo "$CHAVES" | cut -d' ' -f2)

# criação do forum
freechains chains join '#quadro' "$PUB1" "$PUB2" --port=8551

sleep 2		# espera 2 segundos antes de continuar

# semana 0 (dias 0-7)
freechains-host now 0 --port=8551
freechains-host now 0 --port=8552
freechains-host now 0 --port=8553

# Jorge posta uma apresentação ao forum
POST1=$(freechains chain '#quadro' post file 'post1.json' --sign=$PVT1 --port=8551 2>/dev/null)
# Matheus complementa a apresentação
POST2=$(freechains chain '#quadro' post file 'post2.json' --sign=$PVT2 --port=8551 2>/dev/null)

# semana 1 (dias 7-14)
freechains-host now 604800000 --port=8551
freechains-host now 604800000 --port=8552
freechains-host now 604800000 --port=8553

# Francisco (user ativo) entra no forum e sincroniza com os hosts (Gabrie, noob, também, por ser do mesmo nó)
freechains chains join '#quadro' "$PUB1" "$PUB2" --port=8552
freechains --host=localhost:8552 peer localhost:8551 recv '#quadro' --port=8552

# Francisco faz sua primeira postagem e a envia
POST3=$(freechains chain "#quadro" post file 'post3.json' --sign=$PVTAtivo --port=8552 2>/dev/null)
freechains --host=localhost:8552 peer localhost:8551 send '#quadro' --port=8552

# semana 2 (dias 14-21)
freechains-host now 1209600000 --port=8551
freechains-host now 1209600000 --port=8552
freechains-host now 1209600000 --port=8553

# Rafaela (troll) entra no forum
freechains chains join '#quadro' "$PUB1" "$PUB2" --port=8553 # Troll

# Rafaela faz uma postagem ofensiva e se sincroniza com o forum
freechains --host=localhost:8553 peer localhost:8551 recv '#quadro' --port=8553
POST4=$(freechains chain "#quadro" post file 'post4.json' --sign=$PVTTroll --port=8553 2>/dev/null)
freechains --host=localhost:8553 peer localhost:8551 send '#quadro' --port=8553
freechains --host=localhost:8553 peer localhost:8552 send '#quadro' --port=8553

# Gabriela (noob) faz uma pergunta
POST5=$(freechains chain "#quadro" post file 'post5.json' --sign=$PVTNoob --port=8552 2>/dev/null)
freechains --host=localhost:8552 peer localhost:8551 send '#quadro' --port=8552
freechains --host=localhost:8552 peer localhost:8553 send '#quadro' --port=8552

# Francisco faz mais uma postagem e a envia
POST6=$(freechains chain "#quadro" post file 'post6.json' --sign=$PVTAtivo --port=8552 2>/dev/null)
freechains --host=localhost:8552 peer localhost:8551 send '#quadro' --port=8552
freechains --host=localhost:8552 peer localhost:8553 send '#quadro' --port=8552

# Jorge dá like na resposta do Francisco
freechains chain "#quadro" like $POST6 --sign=$PVT1 --port=8551
freechains --host=localhost:8551 peer localhost:8552 send '#quadro' --port=8551
freechains --host=localhost:8551 peer localhost:8553 send '#quadro' --port=8551

# semana 3 (dias 21-28)
freechains-host now 1814400000 --port=8551
freechains-host now 1814400000 --port=8552
freechains-host now 1814400000 --port=8553

# Matheus responde Gabriela e da like em sua mensagem
POST7=$(freechains chain "#quadro" post file 'post7.json' --sign=$PVT2 --port=8551 2>/dev/null)
freechains chain "#quadro" like $POST5 --sign=$PVT2 --port=8551
freechains --host=localhost:8551 peer localhost:8552 send '#quadro' --port=8551
freechains --host=localhost:8551 peer localhost:8553 send '#quadro' --port=8551

# Jorge e Matheus dão deslike na postagem da Rafaela
freechains chain "#quadro" dislike $POST4 --sign=$PVT1 --port=8551
freechains chain "#quadro" dislike $POST4 --sign=$PVT2 --port=8551
freechains --host=localhost:8551 peer localhost:8552 send '#quadro' --port=8551
freechains --host=localhost:8551 peer localhost:8553 send '#quadro' --port=8551

# Jorge faz uma nova postagem
POST8=$(freechains chain "#quadro" post file 'post8.json' --sign=$PVT1 --port=8551 2>/dev/null)
freechains --host=localhost:8551 peer localhost:8552 send '#quadro' --port=8551
freechains --host=localhost:8551 peer localhost:8553 send '#quadro' --port=8551

# Rafaela faz uma postagem de spam
POST9=$(freechains chain "#quadro" post file 'post9.json' --sign=$PVTTroll --port=8553 2>/dev/null)
freechains --host=localhost:8553 peer localhost:8551 send '#quadro' --port=8553
freechains --host=localhost:8553 peer localhost:8552 send '#quadro' --port=8553

# semana 4 (dias 28-35)
freechains-host now 2419200000 --port=8551
freechains-host now 2419200000 --port=8552
freechains-host now 2419200000 --port=8553

# Gabriela (noob) faz uma nova postagem
POST10=$(freechains chain "#quadro" post file 'post10.json' --sign=$PVTNoob --port=8552 2>/dev/null)
freechains --host=localhost:8552 peer localhost:8551 send '#quadro' --port=8552
freechains --host=localhost:8552 peer localhost:8553 send '#quadro' --port=8552

# Francisco faz mais uma postagem
POST11=$(freechains chain "#quadro" post file 'post11.json' --sign=$PVTAtivo --port=8552 2>/dev/null)
freechains --host=localhost:8552 peer localhost:8551 send '#quadro' --port=8552
freechains --host=localhost:8552 peer localhost:8553 send '#quadro' --port=8552

# Jorge e Matheus dão deslike na nova postagem da Rafaela e Jorge responde ao Francisco e dá like em sua última postagem
freechains chain "#quadro" dislike $POST9 --sign=$PVT1 --port=8551
freechains chain "#quadro" dislike $POST9 --sign=$PVT2 --port=8551

POST12=$(freechains chain "#quadro" post file 'post12.json' --sign=$PVT1 --port=8551 2>/dev/null)
POST13=$(freechains chain "#quadro" post file 'post13.json' --sign=$PVT1 --port=8551 2>/dev/null)
freechains chain "#quadro" like $POST11 --sign=$PVT2 --port=8551

freechains --host=localhost:8551 peer localhost:8552 send '#quadro' --port=8551
freechains --host=localhost:8551 peer localhost:8553 send '#quadro' --port=8551

# Rafaela faz uma postagem de spam
POST14=$(freechains chain "#quadro" post file 'post14.json' --sign=$PVTTroll --port=8553 2>/dev/null)
freechains --host=localhost:8553 peer localhost:8551 send '#quadro' --port=8553
freechains --host=localhost:8553 peer localhost:8552 send '#quadro' --port=8553

# semana 5 (dias 35-42)
freechains-host now 3024000000 --port=8551
freechains-host now 3024000000 --port=8552
freechains-host now 3024000000 --port=8553

# Francisco faz mais uma postagem
POST15=$(freechains chain "#quadro" post file 'post15.json' --sign=$PVTAtivo --port=8552 2>/dev/null)
freechains --host=localhost:8552 peer localhost:8551 send '#quadro' --port=8552
#Francisco para de dar SEND pro port 8553, do Troll

# Matheus responde Francisco e dá deslike nas postagens da Rafaela
POST16=$(freechains chain "#quadro" post file 'post16.json' --sign=$PVT2 --port=8551 2>/dev/null)
POST17=$(freechains chain "#quadro" post file 'post17.json' --sign=$PVT2 --port=8551 2>/dev/null)
freechains chain "#quadro" dislike $POST14 --sign=$PVT2 --port=8551
freechains --host=localhost:8551 peer localhost:8552 send '#quadro' --port=8551

# semana 6 (dias 42-49)
freechains-host now 3628800000 --port=8551
freechains-host now 3628800000 --port=8552
freechains-host now 3628800000 --port=8553

# Jorge faz mais uma postagem
POST18=$(freechains chain "#quadro" post file 'post18.json' --sign=$PVT1 --port=8551 2>/dev/null)
freechains --host=localhost:8551 peer localhost:8552 send '#quadro' --port=8551

# Matheus responde Jorge
POST19=$(freechains chain "#quadro" post file 'post19.json' --sign=$PVT2 --port=8551 2>/dev/null)
POST20=$(freechains chain "#quadro" post file 'post20.json' --sign=$PVT2 --port=8551 2>/dev/null)
freechains --host=localhost:8551 peer localhost:8552 send '#quadro' --port=8551

# Francisco responde e da like nas mensagens de Jorge e Matheus
POST21=$(freechains chain "#quadro" post file 'post21.json' --sign=$PVTAtivo --port=8552 2>/dev/null)
freechains chain "#quadro" like $POST18 --sign=$PVTAtivo --port=8552
freechains chain "#quadro" like $POST19 --sign=$PVTAtivo --port=8552
freechains --host=localhost:8552 peer localhost:8551 send '#quadro' --port=8552

# semana 7 (dias 49-56)
freechains-host now 4233600000 --port=8551
freechains-host now 4233600000 --port=8552
freechains-host now 4233600000 --port=8553

# Francisco faz uma postagem
POST22=$(freechains chain "#quadro" post file 'post22.json' --sign=$PVTAtivo --port=8552 2>/dev/null)
freechains --host=localhost:8552 peer localhost:8551 send '#quadro' --port=8552

# Gabriela (noob) faz uma nova postagem respondendo Francisco
POST23=$(freechains chain "#quadro" post file 'post23.json' --sign=$PVTNoob --port=8552 2>/dev/null)
freechains --host=localhost:8552 peer localhost:8551 send '#quadro' --port=8552

# Jorge e Matheus se surpreendem com o aparecimento de Gabriela no chat
POST24=$(freechains chain "#quadro" post file 'post24.json' --sign=$PVT1 --port=8551 2>/dev/null)
freechains --host=localhost:8551 peer localhost:8552 send '#quadro' --port=8551

POST25=$(freechains chain "#quadro" post file 'post25.json' --sign=$PVT2 --port=8551 2>/dev/null)
freechains --host=localhost:8551 peer localhost:8552 send '#quadro' --port=8551

# semana 8 (dias 56-63)
freechains-host now 4838400000 --port=8551
freechains-host now 4838400000 --port=8552
freechains-host now 4838400000 --port=8553

# Gabriela (noob) faz uma nova postagem
POST26=$(freechains chain "#quadro" post file 'post26.json' --sign=$PVTNoob --port=8552 2>/dev/null)
freechains --host=localhost:8552 peer localhost:8551 send '#quadro' --port=8552

# Francisco responde Gabriela e dá like em sua mensagem
POST27=$(freechains chain "#quadro" post file 'post27.json' --sign=$PVTAtivo --port=8552 2>/dev/null)
freechains --host=localhost:8552 peer localhost:8551 send '#quadro' --port=8552
freechains chain "#quadro" like $POST26 --sign=$PVTAtivo --port=8552

# Rafaela se sincroniza, pois pararam de lhe enviar atualizações, e faz uma postagem de spam
freechains --host=localhost:8553 peer localhost:8551 recv '#quadro' --port=8553
freechains --host=localhost:8553 peer localhost:8552 recv '#quadro' --port=8553
POST28=$(freechains chain "#quadro" post file 'post28.json' --sign=$PVTTroll --port=8553 2>/dev/null)
freechains --host=localhost:8553 peer localhost:8551 send '#quadro' --port=8553
freechains --host=localhost:8553 peer localhost:8552 send '#quadro' --port=8553

# semana 9 (dias 63-70)
freechains-host now 5443200000 --port=8551
freechains-host now 5443200000 --port=8552
freechains-host now 5443200000 --port=8553

# Jorge e Matheus respondem Francisco e Gabriela
POST29=$(freechains chain "#quadro" post file 'post29.json' --sign=$PVT1 --port=8551 2>/dev/null)
freechains --host=localhost:8551 peer localhost:8552 send '#quadro' --port=8551

POST30=$(freechains chain "#quadro" post file 'post30.json' --sign=$PVT2 --port=8551 2>/dev/null)
freechains --host=localhost:8551 peer localhost:8552 send '#quadro' --port=8551

CADEIA="#quadro"
PORTA=8551

while true; do
    echo "⏳ Executando script às $(date)..."
	
    echo "Lendo apenas mensagens do consenso da cadeia $CADEIA na porta $PORTA..."
    HASHES=$(freechains chain "$CADEIA" consensus --porcelain --port="$PORTA" 2>/dev/null)
    
    if [ -z "$HASHES" ]; then
        echo "⚠️  Nenhum hash encontrado no consenso"
        echo "✅ Execução finalizada às $(date)"
        echo "🕒 Aguardando 30 minutos..."
        sleep 1800
        continue
    fi

    # Pontuação por tema
    declare -A TEMA_PONTOS=(
        ["FINANCAS"]=5
        ["AVISO URGENTE"]=4
        ["RECLAMACOES"]=3
        ["SERVICOS"]=2
        ["COMEMORACOES"]=1
        ["FESTAS"]=2
    )

    get_likes() {
        local hash="$1"
        local likes=$(freechains chain "$CADEIA" reps "$hash" --port="$PORTA" 2>/dev/null | awk '{print $1}')
        echo "${likes:-0}"
    }

    POSTAGENS=()
    CONTADOR=0

    for h in $HASHES; do
        echo "📄 Processando hash: $h"
        
        # Criar arquivo temporário para o payload
        FILE=$(mktemp)
        
        # Tentar obter o payload
        if ! freechains chain "$CADEIA" get payload "$h" --port="$PORTA" > "$FILE" 2>/dev/null; then
            echo "❌ Erro ao obter payload do hash $h"
            rm -f "$FILE"
            continue
        fi
        
        # Verificar se o arquivo não está vazio
        if [ ! -s "$FILE" ]; then
            echo "❌ Payload vazio para hash $h"
            rm -f "$FILE"
            continue
        fi
        
        # Debug: mostrar conteúdo do arquivo
        echo "📋 Conteúdo do arquivo:"
        cat "$FILE"
        echo ""
        
        # Verificar se é JSON válido - método mais robusto
        if ! jq . "$FILE" >/dev/null 2>&1; then
            echo "❌ JSON inválido no hash $h"
            echo "🔍 Tentando diagnóstico..."
            
            # Verificar se há caracteres não-ASCII
            if ! python3 -c "
import json
import sys
try:
    with open('$FILE', 'r', encoding='utf-8') as f:
        json.load(f)
    print('✅ JSON válido com Python')
    sys.exit(0)
except Exception as e:
    print(f'❌ Erro Python: {e}')
    sys.exit(1)
" 2>/dev/null; then
                echo "❌ JSON inválido mesmo com Python"
                rm -f "$FILE"
                continue
            else
                echo "✅ JSON válido com Python, problema pode ser com jq"
                # Prosseguir mesmo com erro do jq
            fi
        fi

        # Extrair campos do JSON com tratamento de erro mais robusto
        TEMA=$(jq -r '.tema // ""' "$FILE" 2>/dev/null || echo "")
        DATA_POSTAGEM=$(jq -r '.data_postagem // ""' "$FILE" 2>/dev/null || echo "")
        DATA_EVENTO=$(jq -r '.data_evento // ""' "$FILE" 2>/dev/null || echo "")
        TITULO=$(jq -r '.titulo // ""' "$FILE" 2>/dev/null || echo "")
        
        # Se jq falhou, tentar com método alternativo
        if [ -z "$TEMA" ] && [ -z "$TITULO" ]; then
            echo "🔄 jq falhou, tentando método alternativo..."
            
            # Método alternativo usando grep e sed
            TEMA=$(grep -o '"tema"[[:space:]]*:[[:space:]]*"[^"]*"' "$FILE" | sed 's/.*"tema"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
            TITULO=$(grep -o '"titulo"[[:space:]]*:[[:space:]]*"[^"]*"' "$FILE" | sed 's/.*"titulo"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
            DATA_POSTAGEM=$(grep -o '"data_postagem"[[:space:]]*:[[:space:]]*"[^"]*"' "$FILE" | sed 's/.*"data_postagem"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
            DATA_EVENTO=$(grep -o '"data_evento"[[:space:]]*:[[:space:]]*"[^"]*"' "$FILE" | sed 's/.*"data_evento"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
            
            echo "📋 Extração alternativa:"
            echo "   Tema: '$TEMA'"
            echo "   Título: '$TITULO'"
        fi
        
        echo "🔍 Dados extraídos:"
        echo "   Tema: '$TEMA'"
        echo "   Data Postagem: '$DATA_POSTAGEM'"
        echo "   Data Evento: '$DATA_EVENTO'"
        echo "   Título: '$TITULO'"
        
        # Verificar se os campos obrigatórios estão presentes
        if [ -z "$TEMA" ] || [ "$TEMA" = "null" ] || [ -z "$TITULO" ] || [ "$TITULO" = "null" ]; then
            echo "❌ Campos obrigatórios ausentes (tema ou título) no hash $h"
            rm -f "$FILE"
            continue
        fi
        
        # Normalizar tema para maiúsculas
        TEMA_UPPER=$(echo "$TEMA" | tr '[:lower:]' '[:upper:]' | sed 's/[^A-Z ]//g')
        
        # Obter likes
        LIKES=$(get_likes "$h")
        
        echo "   Likes: $LIKES"
        echo "   Tema normalizado: '$TEMA_UPPER'"

        # Calcular pontuação base pelo tema
        PONTOS_TEMA=${TEMA_PONTOS[$TEMA_UPPER]}
        PONTOS=${PONTOS_TEMA:-0}
        
        echo "   Pontos base: $PONTOS"

        # Calcular urgência se há data do evento
        if [ -n "$DATA_EVENTO" ] && [ "$DATA_EVENTO" != "null" ] && [ "$DATA_EVENTO" != "" ]; then
            if command -v date >/dev/null 2>&1; then
                EVENTO_TS=$(date -d "$DATA_EVENTO" +%s 2>/dev/null)
                POST_TS=$(date -d "$DATA_POSTAGEM" +%s 2>/dev/null)
                AGORA_TS=$(date +%s)

                if [ -n "$EVENTO_TS" ] && [ -n "$POST_TS" ] && [ "$AGORA_TS" -lt "$EVENTO_TS" ]; then
                    TOTAL_DIAS=$(( (EVENTO_TS - POST_TS) / 86400 ))
                    RESTANTE=$(( (EVENTO_TS - AGORA_TS) / 86400 ))
                    if [ "$TOTAL_DIAS" -gt 0 ]; then
                        URGENCIA=$(( 5 - (5 * RESTANTE / TOTAL_DIAS) ))
                        [ "$URGENCIA" -lt 0 ] && URGENCIA=0
                        [ "$URGENCIA" -gt 5 ] && URGENCIA=5
                        PONTOS=$((PONTOS + URGENCIA))
                        echo "   Urgência: +$URGENCIA pontos"
                    fi
                fi
            fi
        fi

        # Calcular recência
        if [ -n "$DATA_POSTAGEM" ] && [ "$DATA_POSTAGEM" != "null" ] && command -v date >/dev/null 2>&1; then
            POST_TS=$(date -d "$DATA_POSTAGEM" +%s 2>/dev/null)
            AGORA_TS=$(date +%s)
            if [ -n "$POST_TS" ]; then
                DIF=$((AGORA_TS - POST_TS))
                if [ "$DIF" -le 3600 ]; then
                    PONTOS=$((PONTOS + 2))
                    echo "   Recência: +2 pontos"
                fi
            fi
        fi

        echo "   Pontos finais: $PONTOS"
        echo ""

        # Adicionar à lista de postagens
        POSTAGENS+=("$PONTOS|$LIKES|$TITULO|$h")
        CONTADOR=$((CONTADOR + 1))
        
        rm -f "$FILE"
    done

    echo "📊 Total de postagens processadas: $CONTADOR"

    if [ ${#POSTAGENS[@]} -eq 0 ]; then
        echo "⚠️  Nenhuma postagem válida encontrada"
        echo "✅ Execução finalizada às $(date)"
        echo "🕒 Aguardando 30 minutos..."
        sleep 1800
        continue
    fi

    # Adicionar pontos de popularidade para os 3 mais curtidos
    if [ ${#POSTAGENS[@]} -gt 0 ]; then
        # Ordenar por likes (campo 2) em ordem decrescente
        IFS=$'\n' SORTED_BY_LIKES=($(printf "%s\n" "${POSTAGENS[@]}" | sort -t '|' -k2 -nr))
        
        # Criar nova array com pontos de popularidade
        declare -a POSTAGENS_UPDATED
        for i in "${!POSTAGENS[@]}"; do
            POSTAGENS_UPDATED[$i]="${POSTAGENS[$i]}"
        done
        
        # Adicionar pontos extras para os 3 mais curtidos
        for i in 0 1 2; do
            if [ $i -lt ${#SORTED_BY_LIKES[@]} ]; then
                ENTRY="${SORTED_BY_LIKES[$i]}"
                IFS='|' read -r P L T H <<< "$ENTRY"
                case $i in
                    0) P=$((P + 3));;
                    1) P=$((P + 2));;
                    2) P=$((P + 1));;
                esac
                
                # Encontrar e atualizar na array original
                for j in "${!POSTAGENS[@]}"; do
                    if [[ "${POSTAGENS[$j]}" == *"|$H" ]]; then
                        POSTAGENS_UPDATED[$j]="$P|$L|$T|$H"
                        break
                    fi
                done
            fi
        done
        
        POSTAGENS=("${POSTAGENS_UPDATED[@]}")
    fi

    # Ordenar por pontuação final
    IFS=$'\n' FINAL_SORTED=($(printf "%s\n" "${POSTAGENS[@]}" | sort -t '|' -k1 -nr))

    # Mostrar só as 3 mais relevantes
    echo ""
    echo "=== TOP 3 POSTAGENS MAIS RELEVANTES ==="
    for i in {0..2}; do
        if [ $i -lt ${#FINAL_SORTED[@]} ]; then
            ENTRY="${FINAL_SORTED[$i]}"
            IFS='|' read -r PONTOS LIKES TITULO HASH <<< "$ENTRY"
            echo "[$PONTOS pts | $LIKES likes] $TITULO"
            echo "→ HASH: $HASH"
            echo ""
        fi
    done

    echo "✅ Execução finalizada às $(date)"
    echo "🕒 Aguardando 15 minutos..."
    echo "Use Ctrl + C para interromper manualmente se estiver rodando em um terminal."
    sleep 900  # 900 segundos = 15 minutos
done