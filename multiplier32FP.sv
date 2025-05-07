module multiplier32FP (
	//Entradas
	input logic clk,		//clock global do circuito
	input logic rst_n,		//reset global do circuito  ATIVO EM BAIXO
	input logic start_i,	//indica quando deve ser iniciada uma nova operação de multiplicação
	input logic [31:0] a_i, //dado a ser multiplicado
	input logic [31:0] b_i, //dado a ser multiplicado//flag para indicar que o resultado da operação gerou overflow
	//Saídas
	output logic done_o,			//indica que a multiplicação terminou e o valor de saída é válido (manter ativo por 1 ciclo de clock)
	output logic nan_o,				//flag para indicar que um operando não é um número (manter ativo por 2 ciclos de clock)
	output logic infinit_o,			//flag para indicar que um operando é infinito (manter ativo por 2 ciclos de clock)
	output logic overflow_o,		//flag para indicar que o resultado da operação gerou overflow (manter ativo por 2 ciclos de clock)
	output logic underflow_o,		//flag para indicar que o resultado da operação gerou underflow (manter ativo por 2 ciclos de clock)1
	output logic [31:0] product_o	//resultado da multiplicação
);	
	
	//registrando as entradas:
	logic [31:0] a_i_ff, a_i_s;
	logic [31:0] b_i_ff, b_i_s;

	logic a_i_sign, b_i_sign, flagzero_a_ff, flagzero_b_ff, flagzero_a_s, flagzero_b_s, dirty_a, dirty_b, infinit_a, infinit_b;
	logic [7:0] a_i_exponent, b_i_exponent;
	logic signed [9:0] product_o_exponent_ff, product_o_exponent_s;
	logic [23:0] a_i_mantissa, b_i_mantissa;
	logic [47:0] product_o_mantissa_ff, product_o_mantissa_s;

	logic [31:0] product_o_ff;
	logic done_o_ff;
	logic nan_o_ff;
	logic infinit_o_ff;
	logic overflow_o_ff, underflow_o_ff;
	logic product_o_sign_ff, product_o_sign_s;


    typedef enum logic [2:0] {
    	IDLE,
    	EXPONENT,
        CHECK_INPUTS,
        MULTIPLY,
        CHECK_OVERFLOW_UNDERFLOW,
        DONE
    } state;
    
    state current_state, next_state;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
        	product_o_exponent_s <= 9'h0;
        	product_o_mantissa_s <= 48'h0;
        	product_o_sign_s <= 1'b0;
        	product_o <= 32'h0;
        	overflow_o <= 1'b0;
        	done_o <= 1'b0;
        	nan_o <= 1'b0;
        	infinit_o <= 1'b0;
        	underflow_o <= 1'b0;
        	infinit_o <= 1'b0;
        	nan_o <= 1'b0;
        	done_o <= 1'b0;
        	product_o <= 32'h00000000;
        	flagzero_a_s <= 1'b0;
        	flagzero_b_s <= 1'b0;
        	a_i_s <= 32'b0;
        	b_i_s <= 32'b0;

        end else begin
            current_state <= next_state;
        	product_o_exponent_s <= product_o_exponent_ff;
        	product_o_mantissa_s <= product_o_mantissa_ff;
        	product_o_sign_s <= product_o_sign_ff;
        	flagzero_a_s <= flagzero_a_ff;
        	flagzero_b_s <= flagzero_b_ff;
        	product_o <= product_o_ff;
        	overflow_o <= overflow_o_ff;
        	underflow_o  <= underflow_o_ff;
        	done_o <= done_o_ff;
        	nan_o <= nan_o_ff;
        	infinit_o <= infinit_o_ff;  
        	a_i_s <= a_i_ff;
   			b_i_s <= b_i_ff;     	     	
        end
    end

    always_comb begin
        if (!rst_n) begin
        	next_state = IDLE;
        	product_o_exponent_ff = 9'h0;
        	product_o_mantissa_ff = 38'h0;
        	product_o_sign_ff = 1'b0;
        	product_o_ff = 32'h0;
        	overflow_o_ff = 1'b0;
        	underflow_o_ff = 1'b0;
        	done_o_ff = 1'b0;
        	nan_o_ff = 1'b0;
        	infinit_o_ff = 1'b0;
        	flagzero_a_ff = 1'b0;
        	flagzero_b_ff = 1'b0;
        	dirty_a = 1'b0;
        	dirty_b = 1'b0;
        	infinit_a = 1'b0;
        	infinit_b = 1'b0;
        	a_i_ff = 32'b0;
   			b_i_ff = 32'b0;
        	
        end else begin
        	next_state = current_state;
        	a_i_ff = a_i_s;
        	b_i_ff = b_i_s;
			a_i_sign = a_i_s[31];		//a_i_sign rebebe o valor do sinal para a entrada a_i
			b_i_sign = b_i_s[31];		//b_i_sign rebebe o valor do sinal para a entrada b_i
			a_i_exponent = a_i_ff[30:23]; //a_i_exponent rebebe o valor do sinal para a entrada a_i
			b_i_exponent = b_i_ff[30:23]; //b_i_exponent rebebe o valor do sinal para a entrada b_i
			a_i_mantissa = (a_i_exponent == 8'b0) ? {1'b0, a_i_s[22:0]} : {1'b1, a_i_s[22:0]};  //mantissa não normalizada de a_i
			b_i_mantissa = (b_i_exponent == 8'b0) ? {1'b0, b_i_s[22:0]} : {1'b1, b_i_s[22:0]};  //mantissa não normalizada de b_i	
			done_o_ff = 1'b0;	
			product_o_exponent_ff = product_o_exponent_s;
        	product_o_mantissa_ff = product_o_mantissa_s;
        	product_o_sign_ff = product_o_sign_s ;
        	product_o_ff = product_o;
        	overflow_o_ff = overflow_o;
        	underflow_o_ff = underflow_o;
        	flagzero_a_ff = flagzero_a_s;
        	flagzero_b_ff = flagzero_b_s;
        	nan_o_ff = nan_o;
        	infinit_o_ff = infinit_o; 
        	

	        case (current_state)

	        	IDLE: begin
	        		// a_i_ff = a_i;
        			// b_i_ff = b_i;
        			
	        		if (start_i) begin
	                    next_state = EXPONENT;
		                a_i_ff = a_i;
	        			b_i_ff = b_i;
	        		end
	            end

	            EXPONENT: begin

	            	dirty_a = (a_i_exponent == 8'b0000000) && (a_i_mantissa != 0);
	            	dirty_b = (b_i_exponent == 8'b0000000) && (b_i_mantissa != 0);
			 		flagzero_a_ff = (a_i_s[30:0] == 0);
			 		flagzero_b_ff = (b_i_s[30:0] == 0);
	            	if (!dirty_a && !dirty_b) begin
	            		product_o_exponent_ff = a_i_exponent + b_i_exponent - 127; //cálculo do expoente de product_o
	            		next_state = MULTIPLY;
	            	end else if (dirty_a && dirty_b) begin
	            		underflow_o_ff = 1'b1;
	            		product_o_ff = 32'h00000000;
	            		next_state = DONE;
	            	end else begin
	            		product_o_exponent_ff = a_i_exponent + b_i_exponent - 126;
	            		next_state = MULTIPLY;
	            	end
	            end

	            MULTIPLY: begin
	            	product_o_sign_ff = a_i_sign ^ b_i_sign; //cálculo do sinal de product_o
	                product_o_mantissa_ff = a_i_mantissa * b_i_mantissa; //cálculo da mantissa de product_o;
					
					product_o_exponent_ff = product_o_exponent_s + product_o_mantissa_ff[47];
					product_o_mantissa_ff = product_o_mantissa_ff >> product_o_mantissa_ff[47];

					if (product_o_mantissa_ff == 0) begin
						product_o_exponent_ff = 0;
						product_o_sign_ff = 0;
						next_state = DONE;
					end else if (product_o_mantissa_ff[46] == '0 && product_o_exponent_ff > 0) begin
						 for (int i = 1; i < 25; i++) begin
			                if (product_o_mantissa_ff[46-i] == 1'b1) begin
			                  product_o_mantissa_ff = product_o_mantissa_ff << i ;
			                  product_o_exponent_ff = product_o_exponent_ff - i ;
			                  break;
			                end
			             end
			        end

					if (product_o_exponent_ff >= -22 && product_o_exponent_ff <= 0) begin
						
						product_o_mantissa_ff = product_o_mantissa_ff >> (-product_o_exponent_ff + 1);
						product_o_exponent_ff = '0;
					end

	                next_state = CHECK_INPUTS;
	            end
	            
	            CHECK_INPUTS: begin
	            	
	                nan_o_ff = ((a_i_exponent == 8'hFF && a_i_mantissa[22:0] != 0) ||
			 			(b_i_exponent == 8'hFF && b_i_mantissa[22:0] != 0));
             		infinit_o_ff = (product_o_exponent_s == 8'hFF && product_o_mantissa_s[45:23] == 0);
             		infinit_a = (a_i_exponent == 8'hFF && a_i_mantissa[22:0] == 0);
             		infinit_b = (b_i_exponent == 8'hFF && b_i_mantissa[22:0] == 0);
	                if (nan_o_ff) begin
	                	product_o_ff = 32'h00000000;
	                	next_state = DONE;
	                end else if ((infinit_a && flagzero_b_ff) || (flagzero_a_ff && infinit_b)) begin
	                	product_o_ff = 32'h00000000;
	                	next_state = DONE;
	                end else if ((infinit_a && !infinit_b) || (!infinit_a && infinit_b)) begin
	                	product_o_ff = {product_o_sign_s, 31'h7FFFFFFF};
	                	overflow_o_ff = 1'b1;
	                	next_state =DONE;
	                end else if (infinit_o_ff) begin
	                	product_o_exponent_ff = 8'hFF;
	                	product_o_mantissa_ff = 48'hFFFFFFFFFFFF;
	                	product_o_ff = {product_o_sign_s, product_o_exponent_ff[7:0], product_o_mantissa_ff[45:23]};
	                	next_state = DONE;
	                end else
	                	next_state = CHECK_OVERFLOW_UNDERFLOW;
	            end
	            
	            CHECK_OVERFLOW_UNDERFLOW: begin

		                //underflow_o_ff = ($signed(product_o_exponent_s) < 10'sh01);
		                underflow_o_ff = ((product_o_exponent_s < 0) || ((product_o_exponent_s  == 0) && (product_o_mantissa_s[22:0] != 0) && (product_o_mantissa_s[45:23] == 0)));
		               	overflow_o_ff = ($signed(product_o_exponent_s) > 10'shFE);

		               	if (underflow_o_ff) begin
		               		if (product_o_mantissa_s[45:23] != 0 && product_o_exponent_s == 0) begin
								product_o_ff = {product_o_sign_s, product_o_exponent_s[7:0], product_o_mantissa_s[45:23]};
						 	end else begin
						 		product_o_ff = {product_o_sign_s, 31'h00000000};
		               		end
		               	end else if (overflow_o_ff) begin
		               		product_o_ff = {product_o_sign_s, 31'h7FFFFFFF};
		               	end	else begin
		               		product_o_ff = {product_o_sign_s, product_o_exponent_s[7:0], product_o_mantissa_s[45:23]};
		               	end
		               		next_state = DONE;

	            end            
	            DONE: begin
	            	overflow_o_ff = 1'b0;
	                done_o_ff = 1'b1;
	                next_state = IDLE;
	            end
	        endcase
        end
    end
endmodule

