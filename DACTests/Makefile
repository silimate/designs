VERILATOR_DIR=/usr/local/share/verilator/include
VERILATOR_SRC = $(VERILATOR_DIR)/verilated.cpp $(VERILATOR_DIR)/verilated_vcd_c.cpp 

DACS = sigma_delta_dac_1storder hybrid_2ndorder hybrid_2ndorder_filtered \
	hybrid_pwm_sd hybrid_pwm_sd_2ndorder sigma_delta_dac_2ndorder \
	sigma_delta_dac_3rdorder threshold_dac random_dac pwm_dac 

TESTS = sine fadeout asymmetric constant pcm sweep

all:
	for DAC in $(DACS); do \
		for TEST in $(TESTS); do \
			make $${TEST}_$${DAC}.raw TEST=$$TEST DAC=$$DAC; \
		done; \
	done

clean:
	rm -rf obj_dir
	for TEST in $(TESTS); do \
		rm $${TEST}_*; \
	done;

obj_dir/V%__ALL.a: %.v
	verilator --trace --top-module $* -cc $*.v
	make -C obj_dir -f V$*.mk

$(TEST)_$(DAC): $(TEST).cpp $(VERILATOR_SRC) obj_dir/V$(DAC)__ALL.a
		g++ -DDAC=V$(DAC) -DDACHEADER=\"obj_dir/V$(DAC).h\" -I obj_dir -I$(VERILATOR_DIR) $+ -o $@

$(TEST)_$(DAC).raw: $(TEST)_$(DAC)
		./$(TEST)_$(DAC) <Slide.raw >$(TEST)_$(DAC).raw

