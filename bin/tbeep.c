/*
 * tbeep - Ternary Beep Engine
 * Advanced PC speaker control using ternary state logic
 * Provides smoother, more musical sounds than standard beep
 *
 * Copyright (C) 2025 Sparky Beep Project
 * Licensed under GNU GPL v3
 *
 * Compile: gcc -o tbeep tbeep.c -lm
 * Usage: tbeep -f <frequency> -l <length> [-n -f <freq2> -l <len2> ...]
 *
 * Ternary States:
 *   -1: Speaker membrane pulled back (reverse polarity)
 *    0: Speaker membrane at rest (silence)
 *   +1: Speaker membrane pushed forward (normal polarity)
 *
 * This creates approximate sine waves instead of harsh square waves.
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>
#include <math.h>
#include <sys/io.h>
#include <getopt.h>

#define PC_SPEAKER_PORT 0x61
#define TIMER_CTRL_PORT 0x43
#define TIMER_DATA_PORT 0x42
#define TIMER_FREQ 1193180  // PC timer frequency in Hz

// Ternary states for PC speaker
typedef enum {
    TERNARY_NEG = -1,  // Reverse polarity
    TERNARY_ZERO = 0,  // Off
    TERNARY_POS = 1    // Normal polarity
} TernaryState;

// Beep note structure
typedef struct {
    int frequency;     // Frequency in Hz
    int length;        // Duration in milliseconds
    int delay_after;   // Delay after beep in milliseconds
} BeepNote;

/*
 * Initialize PC speaker hardware
 * Requires root privileges for ioperm
 */
int init_speaker() {
    if (ioperm(PC_SPEAKER_PORT, 1, 1) != 0 ||
        ioperm(TIMER_CTRL_PORT, 1, 1) != 0 ||
        ioperm(TIMER_DATA_PORT, 1, 1) != 0) {
        perror("ioperm: Need root privileges to access PC speaker");
        return -1;
    }
    return 0;
}

/*
 * Set PC speaker to ternary state
 * Uses port 0x61 to control speaker
 */
void set_speaker_state(TernaryState state) {
    uint8_t port_value = inb(PC_SPEAKER_PORT);

    switch(state) {
        case TERNARY_NEG:
            // Attempt reverse polarity (hardware-dependent)
            // Some systems: set bit 0, clear bit 1
            port_value = (port_value & ~0x02) | 0x01;
            break;

        case TERNARY_ZERO:
            // Turn off speaker (clear both bits)
            port_value &= ~0x03;
            break;

        case TERNARY_POS:
            // Normal polarity (set both bits)
            port_value |= 0x03;
            break;
    }

    outb(port_value, PC_SPEAKER_PORT);
}

/*
 * Set PC speaker frequency using timer chip
 */
void set_speaker_frequency(int frequency) {
    int divisor = TIMER_FREQ / frequency;

    // Send control word to timer
    outb(0xB6, TIMER_CTRL_PORT);

    // Send frequency divisor (low byte, high byte)
    outb((uint8_t)(divisor & 0xFF), TIMER_DATA_PORT);
    outb((uint8_t)((divisor >> 8) & 0xFF), TIMER_DATA_PORT);
}

/*
 * Generate ternary sine wave approximation pattern
 * Returns array of ternary states that approximate a sine wave
 */
void generate_ternary_sine_pattern(TernaryState *pattern, int pattern_length) {
    // Ternary quantization of sine wave
    // Divides sine wave into ternary states: -1, 0, +1
    for (int i = 0; i < pattern_length; i++) {
        double t = (double)i / pattern_length;
        double sine_value = sin(2.0 * M_PI * t);

        // Quantize to ternary states
        if (sine_value > 0.33) {
            pattern[i] = TERNARY_POS;
        } else if (sine_value < -0.33) {
            pattern[i] = TERNARY_NEG;
        } else {
            pattern[i] = TERNARY_ZERO;
        }
    }
}

/*
 * Play a tone using ternary state modulation
 * Creates smoother sound than standard binary beep
 */
void play_ternary_tone(int frequency, int duration_ms) {
    // Pattern length affects smoothness
    // More states = smoother, but slower state transitions
    const int pattern_length = 12;
    TernaryState sine_pattern[pattern_length];

    // Generate ternary sine approximation
    generate_ternary_sine_pattern(sine_pattern, pattern_length);

    // Calculate timing
    int period_us = 1000000 / frequency;  // Period in microseconds
    int state_duration_us = period_us / pattern_length;

    // Calculate number of cycles to play
    int total_cycles = (duration_ms * 1000) / period_us;

    // Set speaker frequency (for timer chip)
    set_speaker_frequency(frequency);

    // Play ternary pattern
    for (int cycle = 0; cycle < total_cycles; cycle++) {
        for (int i = 0; i < pattern_length; i++) {
            set_speaker_state(sine_pattern[i]);
            usleep(state_duration_us);
        }
    }

    // Ensure speaker is off
    set_speaker_state(TERNARY_ZERO);
}

/*
 * Play standard binary tone (fallback mode)
 * Compatible with standard beep behavior
 */
void play_binary_tone(int frequency, int duration_ms) {
    set_speaker_frequency(frequency);
    set_speaker_state(TERNARY_POS);
    usleep(duration_ms * 1000);
    set_speaker_state(TERNARY_ZERO);
}

/*
 * Show usage information
 */
void show_usage(const char *program_name) {
    printf("tbeep - Ternary Beep Engine for PC Speaker\n\n");
    printf("USAGE:\n");
    printf("  %s [OPTIONS]\n\n", program_name);
    printf("OPTIONS:\n");
    printf("  -f <freq>     Frequency in Hz (20-20000)\n");
    printf("  -l <length>   Length in milliseconds\n");
    printf("  -D <delay>    Delay after beep in milliseconds\n");
    printf("  -n            Start next beep (allows chaining)\n");
    printf("  -b            Use binary mode (standard beep, not ternary)\n");
    printf("  -h, --help    Show this help message\n\n");
    printf("EXAMPLES:\n");
    printf("  # Play single tone\n");
    printf("  %s -f 440 -l 500\n\n", program_name);
    printf("  # Play sequence (C major chord)\n");
    printf("  %s -f 261 -l 300 -n -f 329 -l 300 -n -f 392 -l 300\n\n", program_name);
    printf("  # Use binary mode (standard beep)\n");
    printf("  %s -b -f 1000 -l 200\n\n", program_name);
    printf("NOTES:\n");
    printf("  - Requires root privileges (sudo)\n");
    printf("  - Ternary mode creates smoother, more musical tones\n");
    printf("  - Binary mode is compatible with standard beep\n");
    printf("  - Not all PC speakers support reverse polarity\n\n");
}

/*
 * Parse command line arguments and play beeps
 */
int main(int argc, char *argv[]) {
    int opt;
    int use_binary_mode = 0;
    BeepNote current_note = {0, 0, 0};
    int note_ready = 0;

    // Options for getopt
    struct option long_options[] = {
        {"help", no_argument, 0, 'h'},
        {0, 0, 0, 0}
    };

    // Initialize speaker hardware
    if (init_speaker() != 0) {
        fprintf(stderr, "ERROR: Failed to initialize PC speaker\n");
        fprintf(stderr, "       Run with sudo: sudo %s ...\n", argv[0]);
        return 1;
    }

    // Parse arguments
    while ((opt = getopt_long(argc, argv, "f:l:D:nbh", long_options, NULL)) != -1) {
        switch (opt) {
            case 'f':
                current_note.frequency = atoi(optarg);
                if (current_note.frequency < 20 || current_note.frequency > 20000) {
                    fprintf(stderr, "ERROR: Frequency must be 20-20000 Hz\n");
                    return 1;
                }
                break;

            case 'l':
                current_note.length = atoi(optarg);
                if (current_note.length < 1) {
                    fprintf(stderr, "ERROR: Length must be positive\n");
                    return 1;
                }
                note_ready = 1;
                break;

            case 'D':
                current_note.delay_after = atoi(optarg);
                break;

            case 'n':
                // Play current note and prepare for next
                if (note_ready && current_note.frequency > 0 && current_note.length > 0) {
                    if (use_binary_mode) {
                        play_binary_tone(current_note.frequency, current_note.length);
                    } else {
                        play_ternary_tone(current_note.frequency, current_note.length);
                    }

                    if (current_note.delay_after > 0) {
                        usleep(current_note.delay_after * 1000);
                    }

                    // Reset for next note
                    current_note.frequency = 0;
                    current_note.length = 0;
                    current_note.delay_after = 0;
                    note_ready = 0;
                }
                break;

            case 'b':
                use_binary_mode = 1;
                break;

            case 'h':
                show_usage(argv[0]);
                return 0;

            default:
                show_usage(argv[0]);
                return 1;
        }
    }

    // Play final note (if any)
    if (note_ready && current_note.frequency > 0 && current_note.length > 0) {
        if (use_binary_mode) {
            play_binary_tone(current_note.frequency, current_note.length);
        } else {
            play_ternary_tone(current_note.frequency, current_note.length);
        }

        if (current_note.delay_after > 0) {
            usleep(current_note.delay_after * 1000);
        }
    }

    // Ensure speaker is off
    set_speaker_state(TERNARY_ZERO);

    return 0;
}
