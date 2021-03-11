module adler32 (
  input rst_n, clock,
  input data_valid,
  input [7:0] data,
  input last_data,
  output checksum_valid,
  output [31:0] checksum
);

  wire ld_A, ld_B, clr;

  // datapath and controller
  adler32_controller CTRL ( rst_n, clock, data_valid, last_data, ld_A, ld_B, clr, checksum_valid );  
  adler32_datapath DP ( rst_n, clock, data, checksum, ld_A, ld_B, clr );


endmodule

module adler32_controller (
  input rst_n, clock,
  input data_valid, last_data,
  output reg ld_A, ld_B, clr, checksum_valid
);

  localparam S0 = 0;  
  localparam S1 = 1; 
  localparam S2 = 2;  
  localparam S3 = 3; 
  localparam S4 = 4;

  reg [1:0] cstate, nstate;

  always @( posedge clock )
    if( !rst_n )
      cstate <= S0;
    else
      cstate <= nstate;
  
  always @*
    case( cstate )
      S0 : begin
        if( !data_valid ) begin
          { checksum_valid, ld_A, ld_B, clr } = 4'b0111;
          nstate = S0;   
	end
        else begin
          { checksum_valid, ld_A, ld_B, clr } = 4'b0000;
          nstate = S1;   
        end     
      end
      
      S1 : begin
        if( data_valid ) begin
	  if ( !last_data ) begin
            { checksum_valid, ld_A, ld_B, clr } = 4'b0000;
            nstate = S1;   
          end
          else begin 
            { checksum_valid, ld_A, ld_B, clr } = 4'b1000;
            nstate = S2;   
          end     
        end
	else begin
            { checksum_valid, ld_A, ld_B, clr } = 4'b0110;
            nstate = S3;             
	end
      end

      S2 : begin
        if( !last_data ) begin
          { checksum_valid, ld_A, ld_B, clr } = 4'b1110;
          nstate = S0;   
	end
        else begin
          { checksum_valid, ld_A, ld_B, clr } = 4'b1110;
          nstate = S2;   
        end   
      end

      S3 : begin
        if( !data_valid ) begin
          { checksum_valid, ld_A, ld_B, clr } = 4'b0110;
          nstate = S3;   
	end
        else begin
          if( !last_data ) begin
            { checksum_valid, ld_A, ld_B, clr } = 4'b0000;
            nstate = S1;   
	  end
          else begin
            { checksum_valid, ld_A, ld_B, clr } = 4'b0000;
            nstate = S2;   
	  end
        end   
      end
    endcase

endmodule

module adler32_datapath (
  input  rst_n, clock,
  input  [ 7:0] data,
  output [31:0] checksum,

  input ld_A, ld_B, clr
);

  reg  [15:0] A, B;
  wire [15:0] modulo_add_A, modulo_add_B;

  // checksum output
  assign checksum = { B, A };

  // checksum calculations
  addition_modulo sum_A (
    A, {8'h00, data}, modulo_add_A );

  addition_modulo sum_B (
    B, modulo_add_A, modulo_add_B );

  // A register
  always @( posedge clock )
    if( !rst_n )
      A <= 1;
    else
      if( clr )
	A <= 1;
      else 
	if( ld_A )
	  A <= A;  
        else
	  A <= modulo_add_A;

  // B register
  always @( posedge clock )
    if( !rst_n )
      B <= 0;
    else
      if( clr )
	B <= 0;
      else 
	if( ld_B )
	  B <= B;  
        else
	  B <= modulo_add_B;

endmodule

module addition_modulo(
  input  [15:0] a, b,
  output [15:0] val
);
 
  wire [15:0] sum = ( a + b );
  
  assign val = (sum < 65521) ? sum : ( sum - 65521 );

endmodule

