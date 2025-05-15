/*
 * Copyright (c) 2025 Jonathan Cai
 * SPDX-License-Identifier: Apache-2.0
 */

 `default_nettype none

module spi_peripheral(
    input wire clk,
    input wire SCLK,
    input wire nCS,
    input wire COPI,
    input wire rst_n,
    output wire [7:0] en_reg_out_7_0,
    output wire [7:0] en_reg_out_15_8,
    output wire [7:0] en_reg_pwm_7_0,
    output wire [7:0] en_reg_pwm_15_8,
    output wire [7:0] pwm_duty_cycle
);

    // Assiging Output Pins
    assign en_reg_out_7_0 = 0；
    assign en_reg_out_15_8 = 0；
    assign en_reg_pwm_7_0 = 0；
    assign en_reg_pwm_15_8 = 0；
    assign pwm_duty_cycle = 0；

    // Flip Flop Buffer.
    reg [2:0] SCLK_buff;
    reg [1:0] nCS_buff;
    reg [1:0] COPI_buff;

    // Max register address in hex
    localparam max_addr = 8'h4;

    // Register Address
    localparam en_out_7_0_addr = 8'h00;
    localparam en_out_15_8_addr = 8'h01;
    localparam en_pwm_7_0_addr = 8'h02;
    localparam en_pwm_15_8_addr = 8'h03;
    localparam pwm_duty_cycle_addr = 8'h04; 

    // Register Values
    reg [7:0] en_out_7_0;
    reg [7:0] en_out_15_8;
    reg [7:0] en_pwm_7_0;
    reg [7:0] en_pwm_15_8;
    reg [7:0] pwm_duty_cycle;

    // Input Registers
    reg [15:0] input_reg; // 1b R/W, 7b address, 8b data
    reg [4:0] SCLK_count = 0;  // Number of SCLKs

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all registers to 0 on reset
            en_out_7_0 <= 8'h00;
            en_out_15_8 <= 8'h00;
            en_pwm_7_0 <= 8'h00;
            en_pwm_15_8 <= 8'h00;
            pwm_duty_cycle <= 8'h00;

            // Reset buffers
            SCLK_buff <= 3'b000;
            nCS_buff <= 2'b00;
            COPI_buff <= 2'b00;  

            // Reset input
            SCLK_count <= 0;
            input_reg <= 16'b0; 
            input_addr <= 7'b0;
            input_data <= 8'b0;

        end else begin
            // Sample async inputs
            SCLK_buff[2] <= {SCLK_buff[1:0], SCLK};
            nCS_buff[1] <= {nCS_buff[0], nCS};
            COPI_buff[1] <= {COPI_buff[0], COPI};

            // Check rising edge of SCLK
            if (SCLK_buff[2] == 1'b0 && SCKL_buff[1] == 1'b1) begin
                // If nCS is low (active)
                if (nCS_buff[1] == 1'b0) begin
                    // Shift input register
                    input_reg <= {input_reg[14:0], COPI_buff[0]};
                    
                    if (SCLK_count == 15) begin
                        input_RW <= input_reg[15];
                        input_addr <= input_reg[14:8];
                        input_data <= input_reg[7:0];
                        SCLK_count <= 0; // Reset SCLK count
                    end else begin
                        SCLK_count <= SCLK_count + 1; // Increment SCLK count
                    end
                end else begin
                    // Clear the input register if nCS is high (inactive)
                    input_reg <= 16'b0;

                end
            end 
        end
    end

endmodule

