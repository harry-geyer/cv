PROJECT_DIR?=.

PROJECT:=cv

COMPILER:=lualatex

SOURCE_DIR:=$(PROJECT_DIR)/src
BUILD_DIR?=$(PROJECT_DIR)/build

VERSION:=$(shell git describe --tag --abbrev=0)

SOURCES:=$(shell find $(SOURCE_DIR) -type f)
DEOBFS:=$(patsubst $(SOURCE_DIR)/%,$(BUILD_DIR)/%,$(SOURCES))
OUTPUT_FMT:=$(PROJECT)_$(VERSION)
OUTPUT:=$(BUILD_DIR)/$(OUTPUT_FMT).pdf $(BUILD_DIR)/$(OUTPUT_FMT).de.pdf

#Obfuscated addresses and numbers to hinder bot scrapers
define TEXT_UNOBF
echo "$(1)" | openssl enc -aes-256-cbc -a -d -salt -pbkdf2 -pass pass:ImpressiveCVHarry
endef
PHONE_NUMBER_BASIC:=$(shell $(call TEXT_UNOBF,"U2FsdGVkX1+RSL6a5JQgye1LndRFiytVVDmBe5VKTDU="))
PHONE_NUMBER_NICE:=$(shell $(call TEXT_UNOBF,"U2FsdGVkX1+FZb0palwYIIy6xf2pYv7F4C2l/2AYwxz4anrI9dxASaZY0YcLlV6d"))
EMAIL_ADDRESS:=$(shell $(call TEXT_UNOBF,"U2FsdGVkX1870KRIgPjCaaqTWef4WFhW60IqD5+/vOOXwwwrm9ZAsjnnXqXwO/4l"))
WEBSITE_URL:=$(shell $(call TEXT_UNOBF,"U2FsdGVkX1/TN/9PTTO1rnzOrPZtDfTKqAzwyBzvr7LM4bKWUPMaaCGrp0DI7ovE"))

default: $(OUTPUT) 

$(DEOBFS): $(BUILD_DIR)/%: $(SOURCE_DIR)/%
	@mkdir -p $(@D)
	sed -e 's|PHONE_NUMBER_BASIC|$(PHONE_NUMBER_BASIC)|g' \
	    -e 's|PHONE_NUMBER_NICE|$(PHONE_NUMBER_NICE)|g' \
		-e 's|EMAIL_ADDRESS|$(EMAIL_ADDRESS)|g' \
		-e 's|WEBSITE_URL|$(WEBSITE_URL)|g' \
		$< > $@

$(BUILD_DIR)/$(OUTPUT_FMT).pdf: $(BUILD_DIR)/cv.tex
	@mkdir -p $(@D)
	$(COMPILER) -jobname=$(OUTPUT_FMT) --output-directory=$(BUILD_DIR) --output-format=pdf $<

$(BUILD_DIR)/$(OUTPUT_FMT).de.pdf: $(BUILD_DIR)/cv.tex
	@mkdir -p $(@D)
	$(COMPILER) -jobname=$(OUTPUT_FMT).de --output-directory=$(BUILD_DIR) --output-format=pdf "\def\german{} \input{$<}"

open: $(OUTPUT)
	xdg-open $^

clean:
	rm -rf $(BUILD_DIR)

.PHONY: open clean

