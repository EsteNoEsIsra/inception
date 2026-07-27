NAME = Inception

DOCKER = docker
COMPOSE = $(DOCKER) compose
USER = israetor

#        SOURCES                                      

MANDATORY_PATH = -f ./src/docker-compose.yml
#BONUS_PATH = -f ./src/docker-compose_bonus.yml
#ELK_PATH = -f ./src/elk.yml
ENV_SAMPLE = ./src/.env.sample

#         COLORS                                   

RED=\033[0;31m
CYAN=\033[0;36m
GREEN=\033[0;32m
YELLOW=\033[0;33m
WHITE=\033[0;97m
BLUE=\033[0;34m
NC=\033[0m # NO COLOR


all : help

up:	
	@if [ ! -f src/.env ]; then \
		echo "$(RED)Error: src/.env file missing. Run 'make setup' first.$(NC)"; \
		exit 1; \
	fi
	@mkdir -p /home/$(USER)/data/wordpress
	@mkdir -p /home/$(USER)/data/mariadb
	@$(COMPOSE) $(MANDATORY_PATH) up --build -d
	@printf "$(GREEN)Inception started successfully!$(NC)\n"
bonus:	
	@if [ ! -f src/.env ]; then \
		echo "$(RED)Error: src/.env file missing. Run 'make setup' first.$(NC)"; \
		exit 1; \
	fi
	@mkdir -p /home/$(USER)/data/wordpress
	@mkdir -p /home/$(USER)/data/mariadb
	@$(COMPOSE) $(MANDATORY_PATH) $(BONUS_PATH) up --build -d
	@printf "$(GREEN)Inception with Bonus started successfully!$(NC)\n"

setup:
	@mkdir -p /home/$(USER)/data/wordpress
	@mkdir -p /home/$(USER)/data/mariadb
	@if [ ! -f src/.env ]; then \
		cp ${ENV_SAMPLE} src/.env; \
		echo "$(GREEN).env created from sample.$(NC)"; \
	else \
		echo "$(YELLOW).env already exists.$(NC)"; \
	fi

it: # usage make it ID=wordpress
	@$(DOCKER) exec -it $(ID) sh
clean:
	@echo "$(RED)Stopping containers...$(NC)"
	@$(COMPOSE) $(MANDATORY_PATH) down 2>/dev/null || true
	@$(COMPOSE) $(MANDATORY_PATH) $(BONUS_PATH) down 2>/dev/null || true
#	@$(COMPOSE) $(ELK_PATH) down 2>/dev/null || true
	@printf "$(RED)Pruning containers and images...$(NC)\n"
	@$(DOCKER) container prune -f
	@$(DOCKER) image prune -a -f
	@printf "$(GREEN)CLEAN COMPLETE!$(NC)\n"

fclean: clean
	@echo "$(RED)Removing local data volumes...$(NC)"
	@sudo rm -rf /home/$(USER)/data
	@$(DOCKER) system prune -a --volumes -f
	@printf "$(GREEN)FULL CLEAN COMPLETE!$(NC)\n"

logs:
	@$(DOCKER) logs -f $(ID)

ps:
	@$(DOCKER) ps -a

images:
	@$(DOCKER) images

re: fclean all


help: 
	@echo "$(CYAN)╔════════════════════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(CYAN)║                        INCEPTION - MAKEFILE HELP                           ║$(NC)"
	@echo "$(CYAN)╚════════════════════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(WHITE)MAIN COMMANDS (Mandatory & Bonus):$(NC)"
	@echo "  $(GREEN)make up$(NC)            - Create directories, verify the .env file, and start the mandatory part"
	@echo "  $(GREEN)make bonus$(NC)         - Start the environment with the additional bonus configuration"
	@echo "  $(GREEN)make setup$(NC)         - Prepare data directories and copy the .env.sample"
	@echo "  $(GREEN)make re$(NC)            - Perform an fclean followed by an all (clean restart)"
	@echo ""
	@echo "$(WHITE)UTILS AND LOGS:$(NC)"
	@echo "  $(GREEN)make it ID=CON...$(NC)  - Open an interactive shell (sh) in the specified container"
	@echo "  $(GREEN)make logs ID=CON...$(NC)- Show real-time logs of the specified container"
	@echo "  $(GREEN)make ps$(NC)            - List all the containers (active and stoped)"
	@echo "  $(GREEN)make images$(NC)        - List all local Docker images"
	@echo ""
	@echo "$(WHITE)CLEANING:$(NC)"
	@echo "  $(GREEN)make clean$(NC)         - Stops Containers and erase the orphan images "
	@echo "  $(GREEN)make fclean$(NC)        - Total cleanup: delete containers, images, and data volumes"
	@echo ""



.PHONY: all up bonus setup it clean fclean logs ps images re help
