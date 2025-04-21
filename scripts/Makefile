# Project directory
PRJ_DIR := $(CURDIR)/..
export PRJ_DIR

# Testbench name
tb_name := reorder_buf_tb

# Output directory
out := $(PRJ_DIR)/temp

# Verilog files
all_verilog := $(shell find -name "*.*v" -o -name "*.*sv")

ifeq ($(gui),1)
  sim_opts += -gui
else
  sim_opts += -c
endif

# ifeq ($(cov),1)
#   cov_opts += -do "coverage save -onexit ../coverage/rtl_questa.ucdb"
# endif

# PHONY targets
.PHONY: run clean

# Run target
# To run GUI, enter "make gui=1" 
run: $(out)/compile.stamp
	@echo -n "Running (log at $(out)/sim.log)..."
	@cd $(out) && vsim $(sim_opts) $(tb_name) -lib work \
	-do "add wave -position insertpoint sim:/$(tb_name)/*; run -a" -voptargs=+acc -wlf waves.wlf $(cov_opts) > sim.log 
	@echo "done"

# Compile target (we depend on .f file and all verilog sources)
$(out)/compile.stamp: compile.f $(all_verilog)
	@echo -n "Compiling (log at $(out)/compile.log)..."
	@mkdir -p $(out)
	@cd $(out) && vlib work > compile.log
	@cd $(out) && vmap work work > compile.log
	@cd $(out) && vlog -sv -f $(CURDIR)/compile.f > compile.log
	@echo "done"  
	@touch $@

# Clean target
clean:
	@echo -n "Removing $(out)..."
	@rm -rf $(out)
	@echo "done"