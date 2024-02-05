# Sistema de Votação 🗳️

## 1. Introdução

### 1.1 Objetivo do Aplicativo
O **Sistema de Votação** foi desenvolvido com o objetivo de modernizar e otimizar o processo de coleta de votos e pesquisas populacionais. Proporcionando uma plataforma eficiente, segura e de fácil utilização para administradores e pesquisadores.

### 1.2 Público-Alvo
O aplicativo é direcionado a duas categorias principais: Administradores, responsáveis pela administração global do sistema, e Pesquisadores, usuários que conduzem pesquisas em regiões específicas.

### 1.3 Funcionalidades Principais
- Autenticação segura para Administradores e Pesquisadores.
- Cadastro de candidatos por Administradores.
- Cadastro de pesquisadores por Administradores.
- Coleta de votos por Pesquisadores.
- Dashboard exclusivo para Administradores com estatísticas e informações consolidadas.
- Visualização de resultados de votos para Administradores.
- Lista de candidatos disponíveis para votação por Pesquisadores.

## 2. Estrutura do Projeto 🏗️

### 2.1 Visão Geral da Estrutura de Diretórios
A estrutura de diretórios do projeto foi organizada de maneira a facilitar a manutenção e expansão do código. Os principais diretórios incluem:
- `lib`: Contém os arquivos-fonte do aplicativo.
- `assets`: Armazena recursos estáticos, como imagens.

### 2.2 Descrição de Cada Módulo
- `lib/pages`: Páginas principais do aplicativo, incluindo Login, Tela Principal, Cadastro de Candidatos, Cadastro de Pesquisadores, Dashboard e Resultados dos Votos.
- `lib/pesquisador/`: Páginas onde somenteo RoleId pesquisador tem acesso.
- `lib/pesquisador/`: RoleId responsável pela Lógica de negócios do aplicativo, incluindo autenticação, cadastro de candidatos, coleta de votos e exibição de resultados e administração da dashboard.

## Telas e Componentes Principais 📸

### 3.1 Tela de Login
Permite autenticação para Administradores e Pesquisadores.

| Tela de Login |
| --- |
| <img src="https://github.com/pedrovictormotasilva/votacaoapli/assets/92291111/81423b80-b976-417f-8574-f5a8b0b31702" width="300"> |

### 3.2 Tela Principal (Administrador e Pesquisador)
Apresenta funcionalidades específicas para cada perfil, como Cadastro de Candidatos, Cadastro de Pesquisadores e Lista de Candidatos.

#### ADM
| Tela ADM 1 | SideBar ADM |
| --- | --- |
| <img src="https://github.com/pedrovictormotasilva/votacaoapli/assets/92291111/c9d0ae7c-cb50-4fe5-a784-ee03ec581902" width="300"> | <img src="https://github.com/pedrovictormotasilva/votacaoapli/assets/92291111/a46fa9a7-428a-46e4-be66-e5780c0589c2" width="300"> |

#### PESQUISADOR
| Tela Pesquisador 1 | SideBar Pesquisador |
| --- | --- |
| <img src="https://github.com/pedrovictormotasilva/votacaoapli/assets/92291111/82b96cfb-005f-4a35-8f47-03be185dce6b" width="300"> | <img src="https://github.com/pedrovictormotasilva/votacaoapli/assets/92291111/8b795041-2dfb-4178-811d-6bf2a8d8bc75" width="300"> |

### 3.3 Tela de Cadastro de Candidatos
Permite que Administradores cadastrem novos candidatos.

| Cadastro de Candidatos |
| --- |
| <img src="https://github.com/pedrovictormotasilva/votacaoapli/assets/92291111/a1e2099e-0fbc-4620-a603-1969a17f9a96" width="300"> |

### 3.4 Tela de Cadastro de Pesquisadores
Habilita Administradores a cadastrarem novos pesquisadores.

| Cadastro de Pesquisadores |
| --- |
| <img src="https://github.com/pedrovictormotasilva/votacaoapli/assets/92291111/d7eac04f-fa6a-410c-b7fc-cf02aadc1f82" width="300"> |

### 3.5 Tela de Dashboard (Administrador)
Exclusiva para o perfil de Administrador, exibe estatísticas e informações relevantes.

| Dashboard 1 | Dashboard 2 | Editar Candidato | Editar Pesquisador |
| --- | --- | --- | --- |
| <img src="https://github.com/pedrovictormotasilva/votacaoapli/assets/92291111/73f76583-4077-43a3-9085-9a31e05341ce" width="300"> | <img src="https://github.com/pedrovictormotasilva/votacaoapli/assets/92291111/0375cb4a-4c4d-4d2e-bb61-7c1530658f9c" width="300"> | <img src="https://github.com/pedrovictormotasilva/votacaoapli/assets/92291111/6e3439ba-5978-4f82-b8b0-0652f24d40a8" width="300"> | <img src="https://github.com/pedrovictormotasilva/votacaoapli/assets/92291111/791564b8-812b-4cd9-b1bc-32f11c0722d0" width="300"> |

### 3.6 Tela de Resultados dos Votos (Administrador)
Mostra os resultados consolidados dos votos para o Administrador.

| Resultados Votos 1 | Resultados Votos 2 |
| --- | --- |
| <img src="https://github.com/pedrovictormotasilva/votacaoapli/assets/92291111/b2caf0d5-a8f6-47e2-81fe-68112edc4d1a" width="300"> | <img src="https://github.com/pedrovictormotasilva/votacaoapli/assets/92291111/ee3d609c-f91f-4310-b310-57a4531ce496" width="300"> |

### 3.7 Tela de Lista de Candidatos (Pesquisador)
Permite que Pesquisadores visualizem a lista de candidatos disponíveis para votação.

#### Caso não tenha candidato cadastrado na região do pesquisador
| Lista de Candidatos Pesquisador |
| --- |
| <img src="https://github.com/pedrovictormotasilva/votacaoapli/assets/92291111/d47aedf9-64ec-4097-b991-0b79dea356cf" width="300"> |

#### Caso tenha candidato cadastrado na região do pesquisador
| Lista de Candidatos Pesquisador |
| --- |
| <img src="https://github.com/pedrovictormotasilva/votacaoapli/assets/92291111/925aa088-3888-40d0-abf9-fd9031452ef6" width="300"> |



## 4. Lógica de Negócios 🧠

### 4.1 Autenticação e Autorização
O sistema utiliza autenticação segura para proteger o acesso às funcionalidades específicas de Administradores e Pesquisadores.

### 4.2 Cadastro de Candidatos
Administradores podem cadastrar novos candidatos, incluindo informações como nome, partido e região.

### 4.3 Cadastro de Pesquisadores
Administradores podem cadastrar novos pesquisadores, associando-os a regiões específicas.

### 4.4 Coleta de Votos
Pesquisadores realizam a coleta de votos, registrando as escolhas dos eleitores.

### 4.5 Exibição de Resultados (Administrador)
Administradores têm acesso a um Dashboard com estatísticas e gráficos sobre os resultados da votação.

### 4.6 Outras Lógicas Específicas
O aplicativo possui lógicas específicas para garantir a integridade e segurança do processo de votação.

## 5. Instruções de Configuração ⚙️

### 5.1 Requisitos do Ambiente
- Certifique-se de ter o Flutter e suas dependências instaladas.

### 5.2 Configuração de Variáveis de Ambiente
- Nenhuma configuração de variáveis de ambiente necessária para a execução padrão do aplicativo.

### 5.3 Instalação de Dependências
1. Clone o repositório em sua máquina local:

```bash
git clone https://github.com/pedrovictormotasilva/votacaoapli 
```

2. Navegue até o diretório do projeto:
   
```bash
cd nome-do-diretorio
```

3. Execute o aplicativo:
   
```bash
flutter run
```

### 5.4 Execução do Aplicativo 🚀

Certifique-se de atender aos requisitos do ambiente e execute o aplicativo usando as instruções fornecidas na seção 5.3.

## 6. Considerações Finais 🌟

### 6.1 Contato e Suporte 📧
- Nome: Pedro Victor Mota Silva
- Email: motasilvapedrovictor@gmail.com
- GitHub: https://github.com/pedrovictormotasilva
- Instagram: pedrovic_mota 

### 6.2 Atualizações Futuras 🔄
O aplicativo pode ser aprimorado e expandido com base nas necessidades futuras. Contribuições e sugestões são bem-vindas para melhorar a funcionalidade e a experiência do usuário.


