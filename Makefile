# Basic Makefile for a Lua/LÖVE game

NAME := Shards-of-Time
VERSION ?= dev
DIST := dist
LOVE ?= love
LUACHECK ?= luacheck
STYLUA ?= stylua

BUILD := $(DIST)/$(NAME)-$(VERSION).love

.PHONY: run lint format build release clean

run:
	$(LOVE) .

lint:
	$(LUACHECK) .

format:
	$(STYLUA) .

$(DIST):
	mkdir -p $(DIST)

build: $(DIST)
	zip -9 -r "$(BUILD)" . -x "$(DIST)/*" ".git/*" "*.love" "*.zip" "**/.DS_Store" "docs/*"

release: build
	@echo "Created $(BUILD)"

clean:
	rm -rf "$(DIST)"


