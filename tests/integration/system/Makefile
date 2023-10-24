PROGRAM := integrate_rest_client
rel: $(PROGRAM)
dev: $(PROGRAM)
deb: $(PROGRAM)
prof: $(PROGRAM)

SHELL          = /bin/bash
RESET          = \033[0m
make_std_color = \033[3$1m      # defined for 1 through 7
make_color     = \033[38;5;$1m  # defined for 1 through 255
WRN_COLOR      = $(strip $(call make_std_color,3))
ERR_COLOR      = $(strip $(call make_std_color,1))
STD_COLOR      = $(strip $(call make_color,3))

COLOR_OUTPUT = 2>&1 |                             \
  while IFS='' read -r line; do                   \
    if  [[ $$line == *:[\ ]error:* ]]; then     \
      echo -e "$(ERR_COLOR)$${line}$(RESET)"; \
    elif [[ $$line == *:[\ ]warning:* ]]; then  \
      echo -e "$(WRN_COLOR)$${line}$(RESET)"; \
    else                                          \
      echo -e "$(STD_COLOR)$${line}$(RESET)"; \
    fi;                                           \
  done; exit $${PIPESTATUS[0]};

CPP := g++
RELEASE_FLAGS := -O3 -s -Wall -Wno-terminate -Wconversion -fpic -std=c++17
DEVEL_FLAGS := -Wall -Werror -Wno-terminate -Wconversion -O0 -ggdb3 -ansi -fpic -std=c++17 -DVERBOSE
DEBUG_FLAGS := $(DEVEL_FLAGS) -DDEBUG
FLAGS := $(RELEASE_FLAGS)

INC_LIBS := -lrest_client

ifeq ($(MAKECMDGOALS),rel)
	FLAGS=$(RELEASE_FLAGS)#	$(info Building a RELEASE version)
else ifeq ($(MAKECMDGOALS),dev)
	FLAGS=$(DEVEL_FLAGS)#	$(info Building a DEVEL version)
else ifeq ($(MAKECMDGOALS),deb)
	FLAGS=$(DEBUG_FLAGS)#	$(info Building a DEBUG version)
else ifeq ($(MAKECMDGOALS),prof)
	FLAGS=$(DEVEL_FLAGS)#	$(info Building a PROFILING version)
else
	FLAGS=$(RELEASE_FLAGS)#	$(info Building a RELEASE version)
endif

INC_FILES := $(shell find . | egrep -w '.*.h|.*.hh' | egrep -v 'unittest|systemtest|integrationtest|acceptancetest')
SRC_FILES := $(shell find . | egrep -w '.*.cc|.*.cpp' | egrep -v 'unittest|systemtest|integrationtest|acceptancetest')
SRC_OBJS  := $(patsubst %.cc,%.o,$(patsubst %.cpp,%.o,$(SRC_FILES)))

$(PROGRAM): $(SRC_OBJS)
	@echo "Linking .................................................................."
	@echo $(CPP) -o $@ $^ $(INC_LIBS) $(FLAGS) $(COLOR_OUTPUT)
	@$(CPP) -o $@ $^ $(INC_LIBS) $(COLOR_OUTPUT)

SRC_EXT := cc cpp

define compile_rule
%.o : %.$1 $(INC_FILES)
	@echo "Compiling ................................................................"
	@echo $$(CPP) -c -o $$@ $$< $$(FLAGS) $$(COLOR_OUTPUT)
	@$$(CPP) -c -o $$@ $$< $$(FLAGS) $$(COLOR_OUTPUT)
endef

$(foreach EXT,$(SRC_EXT),$(eval $(call compile_rule,$(EXT))))

.PHONY: check cleanall run clean
check:
	@echo "INC_FILES  = $(INC_FILES)"
	@echo "SRC_FILES  = $(SRC_FILES)"
	@echo "SRC_OBJS   = $(SRC_OBJS)"

cleanall:
	-rm -f $(SRC_OBJS)
	-rm -f $(PROGRAM)
	-rm -f *.gch
	-find . -name "*.o" -exec rm {} \;
	-find . -name ".*core" -exec rm {} \;
	-find . -regex "./analysis.txt\|.*.out" -exec rm {} \;

run: $(PROGRAM)
	@echo "Run $(PROGRAM) .........................................................."
	@./$(PROGRAM)

clean:
	@find . -name "*.o" -exec rm {} \;
