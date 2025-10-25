PROJECT_DIR?=.

PROJECT:=cv

COMPILER:=lualatex

SOURCE_DIR:=$(PROJECT_DIR)/src
BUILD_DIR?=$(PROJECT_DIR)/build

VERSION:=$(shell git describe --tag --abbrev=0)

SOURCES:=$(shell find $(SOURCE_DIR) -type f)
DEOBFS:=$(patsubst $(SOURCE_DIR)/%,$(BUILD_DIR)/%,$(SOURCES))
OUTPUT_FMT:=$(PROJECT)_$(VERSION)
OUTPUTS:= $(BUILD_DIR)/cover_letter.pdf

#Obfuscated addresses and numbers to hinder bot scrapers
define TEXT_UNOBF
echo "$(1)" | openssl enc -aes-256-cbc -a -d -salt -pbkdf2 -pass pass:ImpressiveCVHarry
endef
PHONE_NUMBER_BASIC:=$(shell $(call TEXT_UNOBF,"U2FsdGVkX1+RSL6a5JQgye1LndRFiytVVDmBe5VKTDU="))
PHONE_NUMBER_NICE:=$(shell $(call TEXT_UNOBF,"U2FsdGVkX1+FZb0palwYIIy6xf2pYv7F4C2l/2AYwxz4anrI9dxASaZY0YcLlV6d"))
EMAIL_ADDRESS:=$(shell $(call TEXT_UNOBF,"U2FsdGVkX1870KRIgPjCaaqTWef4WFhW60IqD5+/vOOXwwwrm9ZAsjnnXqXwO/4l"))
WEBSITE_URL:=$(shell $(call TEXT_UNOBF,"U2FsdGVkX1/TN/9PTTO1rnzOrPZtDfTKqAzwyBzvr7LM4bKWUPMaaCGrp0DI7ovE"))

default: all

$(DEOBFS): $(BUILD_DIR)/%: $(SOURCE_DIR)/%
	@mkdir -p $(@D)
	sed -e 's|PHONE_NUMBER_BASIC|$(PHONE_NUMBER_BASIC)|g' \
	    -e 's|PHONE_NUMBER_NICE|$(PHONE_NUMBER_NICE)|g' \
		-e 's|EMAIL_ADDRESS|$(EMAIL_ADDRESS)|g' \
		-e 's|WEBSITE_URL|$(WEBSITE_URL)|g' \
		$< > $@

define GEN_CV_TARGET
OUTPUTS+=$$(BUILD_DIR)/$$(OUTPUT_FMT)_$1.pdf
OUTPUTS+=$$(BUILD_DIR)/$$(OUTPUT_FMT)_$1.de.pdf

$1: $$(BUILD_DIR)/$$(OUTPUT_FMT)_$1.pdf $$(BUILD_DIR)/$$(OUTPUT_FMT)_$1.de.pdf

$$(BUILD_DIR)/$$(OUTPUT_FMT)_$1.pdf: $$(BUILD_DIR)/cv.tex
	@mkdir -p $$(@D)
	$$(COMPILER) -jobname=$$(OUTPUT_FMT)_$1 --output-directory=$$(BUILD_DIR) --output-format=pdf "$2 \input{$$<}"

$$(BUILD_DIR)/$$(OUTPUT_FMT)_$1.de.pdf: $$(BUILD_DIR)/cv.tex
	@mkdir -p $$(@D)
	$$(COMPILER) -jobname=$$(OUTPUT_FMT)_$1.de --output-directory=$$(BUILD_DIR) --output-format=pdf "\def\german{} $2 \input{$$<}"

open_$1: $$(BUILD_DIR)/$$(OUTPUT_FMT)_$1.pdf
	xdg-open $$^

open_$1_de: $$(BUILD_DIR)/$$(OUTPUT_FMT)_$1.de.pdf
	xdg-open $$^

.PHONY: $1 open_$1 open_$1_de
endef

$(eval $(call GEN_CV_TARGET,embedded,\def\embedded{}))
$(eval $(call GEN_CV_TARGET,software,\def\software{}))

all: $(OUTPUTS)

clean:
	rm -rf $(BUILD_DIR)

$(BUILD_DIR)/cover_letter.pdf: $(BUILD_DIR)/cover_letter.tex
	@mkdir -p $(@D)
	$(COMPILER) -jobname cover_letter --output-directory=$(BUILD_DIR) --output-fmt=pdf $<

.PHONY: all clean

