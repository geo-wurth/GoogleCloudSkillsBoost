# **Instrução para execução de scripts para completar os laboratórios de forma automática**

Para que os scripts automáticos sejam executados, é necessário um prepraro mínimo do cloud shell.

1º - Enviar o arquivo para o cloud shell pelo upload do cloud shell

    Enviar (upload) arquivo para o cloud shell
    Executar o comando ls para verificar a presença do arquivo
    Executar o comando cat nome_do_arquivo.sh para verificar seu conteúdo

2º - Executar os exports obrigatórios do laboratório para preparar as variáveis individuis de cada lab

    export REGION=<your region>
    export ZONE=<your zone>
    export PROJECT_ID=<your project id>

3º - Executar o código para desativar os questionamentos do prompt

    gcloud config set disable_prompts true

4º - Executar o código para dar a permissão necessária para execução do script

    chmod u+x nome_do_arquivo.sh

5º - Ajustar o script para remover os carriage return, caso houve, para não ocorrer problemas na execução do script. Esse comando é necessário pois os scripts foram criados no Windows e por possuírem sistemas de arquivos de diferentes de uma máquina linux podem ocorrer conflitos com esses caractéres especiais

    sed -i -e 's/\r$//' nome_do_arquivo.sh
    
6º - Por fim, podemos executar o script para que a magia aconteça

    ./nome_do_arquivo.sh

<br>

---

## Exemplo de bloco de código para o laboratório

O exemplo abaixo mostra um código executado para o laboratório GSP215, onde os exports obrigatórios são a região e o project id.

    export REGION=us-east1
    export PROJECT_ID=qwiklabs-gcp-00-e010438f4021
    gcloud config set disable_prompts true
    chmod u+x GSP215.sh
    sed -i -e 's/\r$//' GSP215.sh
    ./GSP215.sh

