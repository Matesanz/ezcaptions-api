# Variables de entorno y rutas por defecto
ROOT ?= /workspaces/ffmpeg
FONT_PATH ?= $(ROOT)/fonts
SCRIPTS_PATH ?= $(ROOT)/scripts
OUTPUT_PATH ?= $(ROOT)/output
ASS_PATH ?= $(ROOT)/ass

# Nueva variable para la URL
URL ?= ""
ASS ?= ""
ID ?= ""

.PHONY: process fonts create_ass download burn

process: create_ass download burn remove

# Tarea para listar las fuentes disponibles y sus nombres internos
fonts:
	@chmod +x $(SCRIPTS_PATH)/list_fonts.sh
	@FONT_PATH=$(FONT_PATH) $(SCRIPTS_PATH)/list_fonts.sh

create_ass:
	@chmod +x $(SCRIPTS_PATH)/create_ass.sh
	@$(SCRIPTS_PATH)/create_ass.sh "$(ASS_PATH)/$(ID).ass"

download:
	@chmod +x $(SCRIPTS_PATH)/download_video.sh
	$(SCRIPTS_PATH)/download_video.sh "$(URL)" "$(OUTPUT_PATH)/$(ID).mp4"
	
burn:
	@chmod +x $(SCRIPTS_PATH)/burn_captions.sh
	FONT_PATH=$(FONT_PATH) $(SCRIPTS_PATH)/burn_captions.sh "$(OUTPUT_PATH)/$(ID).mp4" "$(ASS_PATH)/$(ID).ass" "$(OUTPUT_PATH)/$(ID)_burned.mp4"

remove:
	@rm -f "$(OUTPUT_PATH)/$(ID).mp4" "$(ASS_PATH)/$(ID).ass"

test:
	@chmod +x ./scripts/test.sh
	./scripts/test.sh