`timescale 1ns / 1ps

module autocorrelation_spectrum (
    input wire CLK100MHZ,
    input wire signal,
    input reg [23:0] x,
    output reg detected_period_ready,
    output reg [10:0] detected_period
    );
    
    parameter MIN_PERIOD = 100;
    parameter N_PERIODS = 400;
    
    initial detected_period_ready = 0;
    initial detected_period = 0;
//    parameter N_STEPS = N_PERIODS + 2;
    
    reg [10:0] N_PIPE_SEGMENTS = 4;
    reg [10:0] N_STEPS = 512;
    
    reg [10:0] processing_state = 0;
    reg buffer_write_on = 0;
    reg bin_write_on = 0;
    
    
    reg [10:0] pivot_read_select = MIN_PERIOD + N_PERIODS;
    reg [10:0] head_read_select = 0;
    reg [10:0] tail_read_select = 0;
    
    wire [23:0] head_read_value;
    wire [23:0] pivot_read_value;
    wire [23:0] tail_read_value;
    
    reg [10:0] bin_read_select = 0;
    reg [10:0] bin_write_select = 0;
    
    wire [47:0] av_old;
    wire [47:0] cv_old;
    reg [47:0] av_new = 0;
    reg [47:0] cv_new = 0;
    reg [47:0] av_add = 0;
    reg [47:0] cv_add = 0;
    reg [47:0] av_sub = 0;
    reg [47:0] cv_sub = 0;
    
    reg [47:0] diff = 0;
    reg [71:0] diff_norm = 0;
    reg [71:0] min_diff = {71{1'b1}};
    reg [10:0] min_period = 0;

    buffer_2048 head_buffer(
        .CLK100MHZ(CLK100MHZ),
        .write(buffer_write_on),
        .read_select(head_read_select),
        .read_value(head_read_value),
        .write_value(x)
    );

    buffer_2048 pivot_buffer(
        .CLK100MHZ(CLK100MHZ),
        .write(buffer_write_on),
        .read_select(pivot_read_select),
        .read_value(pivot_read_value),
        .write_value(x)
    );     
    
    buffer_2048 tail_buffer(
        .CLK100MHZ(CLK100MHZ),
        .write(buffer_write_on),
        .read_select(tail_read_select),
        .read_value(tail_read_value),
        .write_value(x)
    ); 
 
     state_ram autovariance_states_1(
        .CLK100MHZ(CLK100MHZ),
        .read_addr(bin_read_select),
        .write_addr(bin_write_select),
        .write_on(bin_write_on),
        .write_data(av_new),
        .read_data(av_old)
    ); 
    
    state_ram covariance_states_1(
        .CLK100MHZ(CLK100MHZ),
        .read_addr(bin_read_select),
        .write_addr(bin_write_select),
        .write_on(bin_write_on),
        .write_data(cv_new),
        .read_data(cv_old)
    );
    
    reg signed [23:0] inverse_periods [0:N_PERIODS - 1] = '{
        167772, 166111, 164482, 162885, 161319, 159783, 158275, 156796, 155344, 153919, 
        152520, 151146, 149796, 148470, 147168, 145888, 144631, 143395, 142179, 140985, 
        139810, 138654, 137518, 136400, 135300, 134217, 133152, 132104, 131072, 130055, 
        129055, 128070, 127100, 126144, 125203, 124275, 123361, 122461, 121574, 120699, 
        119837, 118987, 118149, 117323, 116508, 115704, 114912, 114130, 113359, 112598, 
        111848, 111107, 110376, 109655, 108942, 108240, 107546, 106861, 106184, 105517, 
        104857, 104206, 103563, 102927, 102300, 101680, 101067, 100462, 99864, 99273, 
        98689, 98112, 97541, 96978, 96420, 95869, 95325, 94786, 94254, 93727, 
        93206, 92691, 92182, 91678, 91180, 90687, 90200, 89717, 89240, 88768, 
        88301, 87838, 87381, 86928, 86480, 86037, 85598, 85163, 84733,84307, 
        83886, 83468, 83055, 82646, 82241, 81840, 81442, 81049, 80659, 80273, 
        79891, 79512, 79137, 78766, 78398, 78033, 77672, 77314, 76959, 76608, 
        76260, 75915, 75573, 75234, 74898, 74565, 74235, 73908, 73584, 73262, 
        72944, 72628, 72315, 72005, 71697, 71392, 71089, 70789, 70492, 70197, 
        69905, 69615, 69327, 69042, 68759, 68478, 68200, 67923, 67650, 67378, 
        67108, 66841, 66576, 66313, 66052, 65793, 65536, 65280, 65027, 64776, 
        64527, 64280, 64035, 63791, 63550, 63310, 63072, 62836, 62601, 62368, 
        62137, 61908, 61680, 61455, 61230, 61008, 60787, 60567, 60349, 60133, 
        59918, 59705, 59493, 59283, 59074, 58867, 58661, 58457, 58254, 58052, 
        57852, 57653, 57456, 57260, 57065, 56871, 56679, 56488, 56299, 56111, 
        55924, 55738, 55553, 55370, 55188, 55007, 54827, 54648, 54471, 54295, 
        54120, 53946, 53773, 53601, 53430, 53261, 53092, 52924, 52758, 52593, 
        52428, 52265, 52103, 51941, 51781, 51622, 51463, 51306, 51150, 50994, 
        50840, 50686, 50533, 50382, 50231, 50081, 49932, 49784, 49636, 49490, 
        49344, 49200, 49056, 48913, 48770, 48629, 48489, 48349, 48210, 48072, 
        47934, 47798, 47662, 47527, 47393, 47259, 47127, 46995, 46863, 46733, 
        46603, 46474, 46345, 46218, 46091, 45964, 45839, 45714, 45590, 45466, 
        45343, 45221, 45100, 44979, 44858, 44739, 44620, 44501, 44384, 44267, 
        44150, 44034, 43919, 43804, 43690, 43577, 43464, 43351, 43240, 43129, 
        43018, 42908, 42799, 42690, 42581, 42473, 42366, 42259, 42153, 42048, 
        41943, 41838, 41734, 41630, 41527, 41425, 41323, 41221, 41120, 41020, 
        40920, 40820, 40721, 40622, 40524, 40427, 40329, 40233, 40136, 40041, 
        39945, 39850, 39756, 39662, 39568, 39475, 39383, 39290, 39199, 39107, 
        39016, 38926, 38836, 38746, 38657, 38568, 38479, 38391, 38304, 38216, 
        38130, 38043, 37957, 37871, 37786, 37701, 37617, 37532, 37449, 37365, 
        37282, 37200, 37117, 37035, 36954, 36873, 36792, 36711, 36631, 36551, 
        36472, 36393, 36314, 36235, 36157, 36080, 36002, 35925, 35848, 35772, 
        35696, 35620, 35544, 35469, 35394, 35320, 35246, 35172, 35098, 35025, 
        34952, 34879, 34807, 34735, 34663, 34592, 34521, 34450, 34379, 34309, 
        34239, 34169, 34100, 34030, 33961, 33893, 33825, 33756, 33689, 33621
    };
   
    // control processing state
    always @(posedge CLK100MHZ) begin 
        if (processing_state == 0) begin
            if (signal) begin
                processing_state <= 1;
            end
        end
        else begin
            processing_state <= (processing_state + 1) % N_STEPS;
        end
    end
    
    parameter BIN_READ_SELECT_START = 3;
    always @(posedge CLK100MHZ) begin
        if (processing_state <= BIN_READ_SELECT_START) begin
            bin_read_select <= 0;
        end
        else if (processing_state < BIN_READ_SELECT_START + N_PERIODS) begin
            bin_read_select <= bin_read_select + 1;
        end
    end

    parameter BIN_WRITE_SELECT_START = BIN_READ_SELECT_START + 2;
    always @(posedge CLK100MHZ) begin
        if (processing_state <= BIN_WRITE_SELECT_START) begin
            bin_write_select <= 0;
        end
        else if (processing_state < BIN_WRITE_SELECT_START + N_PERIODS) begin
            bin_write_select <= bin_write_select + 1;
        end
        else begin
            bin_write_select <= 0;
        end
    end

    always @(posedge CLK100MHZ) begin
        if (processing_state == BIN_WRITE_SELECT_START) begin
            bin_write_on <= 1;
        end
        else if (processing_state == BIN_WRITE_SELECT_START + N_PERIODS) begin
            bin_write_on <= 0;
        end
    end
    
    // control read selects
    parameter BUFFER_READ_START = 2;
    always @(posedge CLK100MHZ) begin
        if (processing_state <= BUFFER_READ_START) begin
            head_read_select <= N_PERIODS;
            tail_read_select <= N_PERIODS + 2 * MIN_PERIOD;
        end
        else if (processing_state <= BUFFER_READ_START + N_PERIODS) begin
            head_read_select <= head_read_select - 1;
            tail_read_select <= tail_read_select + 1;
        end
        else begin
            head_read_select <= 0;
            tail_read_select <= 0;
        end
    end    

    // pipeline logic
    var reg [10:0] period_norm_idx;
    var reg [23:0] period_norm;
    always @(posedge CLK100MHZ) begin    
        // stage 0
        if (processing_state == 1) begin
            buffer_write_on <= 1;
        end
        
        // stage 1 
        if (processing_state == 2) begin
            buffer_write_on <= 0;
        end
    
        // stage 2
        if (processing_state >= BUFFER_READ_START + 2) begin
            av_add <= head_read_value * head_read_value;
            av_sub <= tail_read_value * tail_read_value;
//            av_sub <= 0;
                
            cv_add <= head_read_value * pivot_read_value;
            cv_sub <= pivot_read_value * tail_read_value;
            
//            bin_read_select <= 0;
        end
        
        // stage 3 
        if ((processing_state >= BUFFER_READ_START + 3) && (processing_state <= BUFFER_READ_START + 3 + N_PERIODS)) begin
            av_new <= av_old + (av_add - av_sub);
            cv_new <= cv_old + (cv_add - cv_sub);
//            bin_read_select <= bin_read_select + 1;
        end
        else begin
            av_new <= 0;
            cv_new <= 0;
        end
        
        // state 4
        if ((processing_state >= BUFFER_READ_START + 4) & (processing_state < BUFFER_READ_START + N_PERIODS + 5)) begin
            diff <= av_new - 2 * cv_new;
            period_norm <= inverse_periods[processing_state - 6];
        end

        
        // state 5
        if (processing_state >= BUFFER_READ_START + 5) begin
//            period_norm_idx = processing_state - 6;
//            period_norm = inverse_periods[period_norm_idx];
//            diff_norm <= diff + processing_state;
            diff_norm <= diff * period_norm;
        end
        
        // state 6
        if (processing_state >= N_PERIODS + 8) begin
            min_diff <= {47{1'b1}};
            min_period <= MIN_PERIOD;
        end
        else if (processing_state >= 8) begin
            if (diff_norm < min_diff) begin
                min_diff <= diff_norm;
                min_period <= MIN_PERIOD + processing_state - 8;
            end
        end
        
        if (processing_state == N_PERIODS + 8) begin
           detected_period <= min_period; 
           detected_period_ready <= 1;
        end
        else begin
            detected_period_ready <= 0;
        end
    end

endmodule
