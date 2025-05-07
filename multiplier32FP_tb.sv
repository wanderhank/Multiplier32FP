module multiplier32FP_tb;
    // Sinais do DUT
    logic [31:0] a_i, b_i;
    logic clk, rst_n, start_i;
    logic [31:0] product_o;
    logic nan_o, overflow_o, underflow_o, done_o, infinit_o;
    
    // Instância do DUT
    multiplier32FP inst_multiplicador32
        (
            .clk         (clk),
            .rst_n       (rst_n),
            .start_i     (start_i),
            .a_i         (a_i),
            .b_i         (b_i),
            .done_o      (done_o),
            .nan_o       (nan_o),
            .infinit_o   (infinit_o),
            .overflow_o  (overflow_o),
            .underflow_o (underflow_o),
            .product_o   (product_o)
        );


    
    // Geração de clock - período de 10ns
    always #5 clk = ~clk;
    
    // Variáveis para o arquivo de teste
    integer test_file;
    integer scan_result;
    logic [31:0] expected_product;
    integer num_tests;
    integer errors;
    
    // Task para exibir resultados do teste
    task display_test_result;
        input integer test_number;
        begin
            if (product_o !== expected_product) begin
                $display("ERRO - Teste %0d", test_number);
                $display("Entrada A    : %h", a_i);
                $display("Entrada B    : %h", b_i);
                $display("Esperado     : %h", expected_product);
                $display("Obtido       : %h", product_o);
                $display("Flags - NaN: %b, Overflow: %b, Underflow: %b, Infinito: %b", 
                         nan_o, overflow_o, underflow_o, infinit_o);
                $display("----------------------------------------");
                errors = errors + 1;
            end else begin
                $display("PASSOU - Teste %0d", test_number);
                $display("Entrada A    : %h", a_i);
                $display("Entrada B    : %h", b_i);
                $display("Resultado    : %h", product_o);
                $display("----------------------------------------");
            end
        end
    endtask
    
    // Processo principal de teste
    initial begin
        // Inicialização
        clk = 0;
        rst_n = 0;
        start_i = 0;
        errors = 0;
        num_tests = 0;
        
        // Reset
        repeat (2) @(posedge clk);
        rst_n =1;
        repeat (8) @(posedge clk);
        
        // Abre arquivo de teste
        test_file = $fopen("vetor.txt", "r");
        if (test_file == 0) begin
            $display("ERRO: Não foi possível abrir test_vectors.txt");
            $finish;
        end
        
        $display("\nIniciando testes do multiplicador IEEE 754...\n");
        
        // Loop de teste
        while (!$feof(test_file)) begin
            // Lê uma linha do arquivo
            scan_result = $fscanf(test_file, "%h %h %h\n", a_i, b_i, expected_product);
            
            if (scan_result == 3) begin
                // Inicia multiplicação
                start_i = 1;
                @(posedge clk);
                start_i = 0;
                
                // Espera completar
                @(posedge done_o);
                #1; // Pequeno atraso para estabilizar
                
                // Verifica resultado
                display_test_result(num_tests);
                
                num_tests = num_tests + 1;
                repeat (2) @(posedge clk); // Espera próximo ciclo
            end
        end
        
        // Relatório final
        $display("\nRelatório Final dos Testes");
        $display("Total de testes: %0d", num_tests);
        $display("Total de erros : %0d", errors);
        $display("Taxa de acerto : %0.2f%%\n", 
                 ((num_tests - errors) * 100.0) / num_tests);
        
        $fclose(test_file);
        $finish;
    end
    
    // Monitor de timeout
    initial begin
        #1000000; // 1ms timeout
        $display("ERRO: Timeout - Teste excedeu o tempo máximo!");
        $finish;
    end
    
endmodule