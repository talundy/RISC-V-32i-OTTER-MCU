`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Thomas Lundy
// 
// Create Date: 05/13/24 07:29 PM
// Design Name: Pipelined Decoder (No Hazards)
// Module Name: PL_Decoder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//`include "opcodes.svh"

module OTTER_PL_Decoder(
    input [6:0] CU_OPCODE,
    input [2:0] CU_FUNC3,
    input [6:0] CU_FUNC7,
    input CU_BR_EQ,
    input CU_BR_LT,
    input CU_BR_LTU,
	//input rst,	// need to be fully-fleshed out
	//input intr,	// nneeds to be implemented
    input intTaken,
    output logic CU_ALU_SRCA,
    output logic [1:0] CU_ALU_SRCB,
    output logic [3:0] CU_ALU_FUN,
    output logic [1:0] CU_RF_WR_SEL,   
    output logic [3:0] CU_PCSOURCE,
	output logic PC_WRITE,
	output logic REG_WRITE,
	output logic MEM_WRITE,
	output logic MEM_READ_1,	// Instruction Memory
	output logic MEM_READ_2		// Data Memory
   );
        typedef enum logic [6:0] {
                   LUI      = 7'b0110111,
                   AUIPC    = 7'b0010111,
                   JAL      = 7'b1101111,
                   JALR     = 7'b1100111,
                   BRANCH   = 7'b1100011,
                   LOAD     = 7'b0000011,
                   STORE    = 7'b0100011,
                   OP_IMM   = 7'b0010011,
                   OP       = 7'b0110011,
                   SYSTEM   = 7'b1110011
        } opcode_t;
        
        
        typedef enum logic [2:0] {
                Func3_CSRRW  = 3'b001,
                Func3_CSRRS  = 3'b010,
                Func3_CSRRC  = 3'b011,
                Func3_CSRRWI = 3'b101,
                Func3_CSRRSI = 3'b110,
                Func3_CSRRCI = 3'b111,
                Func3_PRIV   = 3'b000       //mret
        } funct3_system_t;

       
        opcode_t OPCODE;
        assign OPCODE = opcode_t'(CU_OPCODE);
        
        logic brn_cond;
        //DECODING  (does not depend on state)  ////////////////////////////////////////////
       //SEPERATE DECODER
       // assign CU_ALU_FUN = (CU_OPCODE!=LUI)? (CU_OPCODE== )? {CU_FUNC7[5],CU_FUNC3}:4'b1001 ;
        always_comb
            case(CU_OPCODE)
                OP_IMM: CU_ALU_FUN= (CU_FUNC3==3'b101)?{CU_FUNC7[5],CU_FUNC3}:{1'b0,CU_FUNC3};
                LUI,SYSTEM: CU_ALU_FUN = 4'b1001;
                OP: CU_ALU_FUN = {CU_FUNC7[5],CU_FUNC3};
//                AUIPC: 4'b0;
//                LOAD: 4'b0;
//                STORE: 4'b0;
                default: CU_ALU_FUN = 4'b0;
            endcase
            
            always_comb
            case(CU_FUNC3)
                        3'b000: brn_cond = CU_BR_EQ;     //BEQ 
                        3'b001: brn_cond = ~CU_BR_EQ;    //BNE
                        3'b100: brn_cond = CU_BR_LT;     //BLT
                        3'b101: brn_cond = ~CU_BR_LT;    //BGE
                        3'b110: brn_cond = CU_BR_LTU;    //BLTU
                        3'b111: brn_cond = ~CU_BR_LTU;   //BGEU
                        default: brn_cond =0;
            endcase
            
         always_comb
         begin
                case(CU_OPCODE)
                    JAL:    CU_RF_WR_SEL=0;
                    JALR:    CU_RF_WR_SEL=0;
                    LOAD:    CU_RF_WR_SEL=2;
                    SYSTEM:  CU_RF_WR_SEL=1;
                    default: CU_RF_WR_SEL=3; 
                endcase
            //else CU_RF_WR_SEL=3;   
          end   
          
          
         always_comb
         begin
            case(CU_OPCODE)
                STORE:  CU_ALU_SRCB=2;  //S-type
                LOAD:   CU_ALU_SRCB=1;  //I-type
                JAL:    CU_ALU_SRCB=1;  //I-type
                OP_IMM: CU_ALU_SRCB=1;  //I-type
                AUIPC:  CU_ALU_SRCB=3;  // U-type (special) LUI does not use B
                default:CU_ALU_SRCB=0;  //R-type    //OP  BRANCH-does not use
            endcase
          //else CU_ALU_SRCB=3;
         end
         
         always_comb begin
                case(CU_OPCODE)
                    JAL: CU_PCSOURCE =3'b011;
                    JALR: CU_PCSOURCE=3'b001;
                    BRANCH: CU_PCSOURCE=(brn_cond)?3'b010:2'b000;
                    SYSTEM: CU_PCSOURCE = (CU_FUNC3==Func3_PRIV)? 3'b101:3'b000;
                    default: CU_PCSOURCE=3'b000; 
                endcase
                if(intTaken)    
                    CU_PCSOURCE=3'b100;   
        end
         
//////// PIPELINE SIGNALS ///////////////////////////////////////////////	
		// PCWrite (driven high on B-type, jal, jalr, & mret)
		
		// regWrite (driven high on U-type, I-type, R-type, jal, & csrrw)
		always_comb begin
			case(CU_OPCODE)
				LUI: REG_WRITE = 1;
				AUIPC: REG_WRITE = 1;
				OP_IMM: REG_WRITE = 1;
				OP: REG_WRITE = 1; // R-type
				JAL: REG_WRITE = 1;
				SYSTEM: REG_WRITE = 1; // csrrw
				default: REG_WRITE = 0;
			endcase
		end

		// memWrite(2-DataMemory) (driven high on S-type)
		always_comb begin
			case(CU_OPCODE)
				STORE: MEM_WRITE = 1;
				default: MEM_WRITE = 0;
			endcase
		end	

		// memRead1 (Ins. mem.) (driven high for no hazards))
		MEM_READ_1 = 1;	

		// memRead2 (Data mem.) (driven high for load instrutions)
		always_comb begin
			case(CU_OPCODE)
				LOAD: MEM_READ_2 = 1;
				default: MEM_READ_2 = 0;
			endcase
		end
//////// END OF PIPELINE-ADDED DECODER SIGNALS /////////////////////////////


       assign CU_ALU_SRCA = (CU_OPCODE==LUI || CU_OPCODE==AUIPC) ? 1 : 0;
                

endmodule
