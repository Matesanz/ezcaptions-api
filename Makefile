# How to call this Makefile:
# make <target> PARAM1=value1 PARAM2=value2 ...

# Variables de entorno y rutas por defecto
ROOT ?= .
FONT_PATH ?= $(ROOT)/fonts
SCRIPTS_PATH ?= $(ROOT)/scripts
OUTPUT_PATH ?= $(ROOT)/output
ASS_PATH ?= $(ROOT)/ass
BUCKET_NAME ?= ezcaptions-outputs

# Nueva variable para la URL
URL ?= ""
ASS ?= ""
ID ?= ""

.PHONY: process fonts create_ass download burn upload remove

process: create_ass download burn upload

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

upload:
	@chmod +x $(SCRIPTS_PATH)/upload_with_signed_url.sh
	@$(SCRIPTS_PATH)/upload_with_signed_url.sh "$(OUTPUT_PATH)/$(ID)_burned.mp4" "$(BUCKET_NAME)" "$(ID)_burned.mp4"

remove:
	@rm -f "$(OUTPUT_PATH)/$(ID).mp4" "$(ASS_PATH)/$(ID).ass"

test:
	@chmod +x ./scripts/test.sh
	./scripts/test.sh