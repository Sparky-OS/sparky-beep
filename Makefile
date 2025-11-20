# Makefile for Sparky Beep
# Compiles the ternary beep engine

CC = gcc
CFLAGS = -Wall -Wextra -O2
LDFLAGS = -lm

# Directories
BIN_DIR = bin
INSTALL_DIR = /usr/bin

# Targets
TBEEP_SRC = $(BIN_DIR)/tbeep.c
TBEEP_BIN = $(BIN_DIR)/tbeep

.PHONY: all clean install uninstall help

# Default target
all: $(TBEEP_BIN)

# Compile tbeep
$(TBEEP_BIN): $(TBEEP_SRC)
	@echo "Compiling ternary beep engine..."
	$(CC) $(CFLAGS) -o $@ $< $(LDFLAGS)
	@echo "Done! Run 'sudo make install' to install system-wide."

# Install tbeep
install: $(TBEEP_BIN)
	@echo "Installing tbeep to $(INSTALL_DIR)..."
	@install -m 755 $(TBEEP_BIN) $(INSTALL_DIR)/tbeep
	@echo "Installed successfully!"
	@echo ""
	@echo "Usage: sudo tbeep -f 440 -l 500"

# Uninstall tbeep
uninstall:
	@echo "Uninstalling tbeep from $(INSTALL_DIR)..."
	@rm -f $(INSTALL_DIR)/tbeep
	@echo "Uninstalled successfully!"

# Clean compiled files
clean:
	@echo "Cleaning compiled files..."
	@rm -f $(TBEEP_BIN)
	@echo "Clean complete!"

# Help message
help:
	@echo "Sparky Beep Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  make         - Compile tbeep (ternary beep engine)"
	@echo "  make install - Install tbeep to $(INSTALL_DIR) (requires sudo)"
	@echo "  make uninstall - Remove tbeep from $(INSTALL_DIR) (requires sudo)"
	@echo "  make clean   - Remove compiled binaries"
	@echo "  make help    - Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make                    # Compile"
	@echo "  sudo make install       # Install system-wide"
	@echo "  sudo tbeep -f 440 -l 500  # Test ternary beep"
