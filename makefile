# Define compilation type
#OSTYPE=msys
#OSTYPE=oda320
#OSTYPE=odgcw
OSTYPE=retrofwrs97

PRGNAME     = potator

# define regarding OS, which compiler to use
ifeq "$(OSTYPE)" "msys"	
EXESUFFIX = .exe
TOOLCHAIN = /c/MinGW32
CC          = $(TOOLCHAIN)/bin/gcc
CCP         = $(TOOLCHAIN)/bin/g++
LD          = $(TOOLCHAIN)/bin/g++
else
ifeq "$(OSTYPE)" "oda320"	
TOOLCHAIN = /opt/opendingux-toolchain/usr
else
TOOLCHAIN = /opt/gcw0-toolchain/usr
endif
EXESUFFIX = .dge
CC  = $(TOOLCHAIN)/bin/mipsel-linux-gcc
CCP = $(TOOLCHAIN)/bin/mipsel-linux-g++
LD  = $(TOOLCHAIN)/bin/mipsel-linux-g++
endif
ifeq "$(OSTYPE)" "retrofwrs97"
TOOLCHAIN = /opt/mipsel-linux-uclibc
else
TOOLCHAIN = /opt/rs97tools
endif
EXESUFFIX = .dge
CC  = $(TOOLCHAIN)/bin/mipsel-linux-gcc
CCP = $(TOOLCHAIN)/bin/mipsel-linux-g++
LD  = $(TOOLCHAIN)/bin/mipsel-linux-g++


# add SDL dependencies
SDL_LIB     = $(TOOLCHAIN)/lib
SDL_INCLUDE = $(TOOLCHAIN)/include


# change compilation / linking flag options
ifeq "$(OSTYPE)" "msys"	
F_OPTS		=-fomit-frame-pointer -ffunction-sections -ffast-math -fsingle-precision-constant 
CC_OPTS		= -O2 -D_ODSDL_ -DMAX__PATH=1024 -g $(F_OPTS)
CFLAGS		= -I$(SDL_INCLUDE) $(CC_OPTS)
CXXFLAGS	=$(CFLAGS) 
LDFLAGS     = -L$(SDL_LIB) -lmingw32 -lSDLmain -lSDL -mwindows
else
F_OPTS = -fomit-frame-pointer -ffunction-sections -ffast-math -fsingle-precision-constant 
ifeq "$(OSTYPE)" "oda320"
CC_OPTS		= -O2 -mips32 -msoft-float -G0  -D_ODSDL_ -DMAX__PATH=1024  $(F_OPTS)
else
CC_OPTS		= -O2 -mips32 -mhard-float -G0  -D_ODSDL_ -DMAX__PATH=1024 $(F_OPTS)
endif
CFLAGS		= -I$(SDL_INCLUDE) -D_OPENDINGUX_ $(CC_OPTS)
CXXFLAGS	= $(CFLAGS) 
LDFLAGS		= -L$(SDL_LIB) $(CC_OPTS) -lSDL
endif
ifeq "$(OSTYPE)" "retrofwrs97"
CC_OPTS		= -O2 -mips32 -mhard-float -G0  -D_OPENDINGUX_  $(F_OPTS)
CFLAGS		= -I$(SDL_INCLUDE) -DOPENDINGUX $(CC_OPTS)
CXXFLAGS	= $(CFLAGS) 
LDFLAGS		= -L$(SDL_LIB) $(CC_OPTS) -lSDL
endif

# Files to be compiled
SRCDIR    = ./common/m6502 ./common ./platform/rs97
VPATH     = $(SRCDIR)
SRC_C   = $(foreach dir, $(SRCDIR), $(wildcard $(dir)/*.c))
SRC_CP   = $(foreach dir, $(SRCDIR), $(wildcard $(dir)/*.cpp))
OBJ_C   = $(notdir $(patsubst %.c, %.o, $(SRC_C)))
OBJ_CP   = $(notdir $(patsubst %.cpp, %.o, $(SRC_CP)))
OBJS     = $(OBJ_C) $(OBJ_CP)

# Rules to make executable
$(PRGNAME)$(EXESUFFIX): $(OBJS)  
ifeq "$(OSTYPE)" "msys"	
	$(LD) $(CFLAGS) -o $(PRGNAME)$(EXESUFFIX) $^ $(LDFLAGS)
else
	$(LD) $(LDFLAGS) -o $(PRGNAME)$(EXESUFFIX) $^
endif

$(OBJ_C) : %.o : %.c
	$(CC) $(CFLAGS) -c -o $@ $<

$(OBJ_CP) : %.o : %.cpp
	$(CCP) $(CXXFLAGS) -c -o $@ $<
# Big thanks to pingflood for this ipk code!
ipk:  $(BUILD) $(TARGET)
	@rm -rf /tmp/.potator-ipk/ && mkdir -p /tmp/.potator-ipk/root/home/retrofw/emus/potator /tmp/.potator-ipk/root/home/retrofw/apps/gmenu2x/sections/emulators /tmp/.potator-ipk/root/home/retrofw/apps/gmenu2x/sections/emulators.systems
	@cp -r potator.dge distrib/potator/potator.png /tmp/.potator-ipk/root/home/retrofw/emus/potator
	@cp distrib/potator/potator.lnk /tmp/.potator-ipk/root/home/retrofw/apps/gmenu2x/sections/emulators
	@sed "s/^Version:.*/Version: $$(date +%Y%m%d)/" ipkfiles/control > /tmp/.potator-ipk/control
	@cp ipkfiles/conffiles /tmp/.potator-ipk/
	@tar --owner=0 --group=0 -czvf /tmp/.potator-ipk/control.tar.gz -C /tmp/.potator-ipk/ control conffiles
	@tar --owner=0 --group=0 -czvf /tmp/.potator-ipk/data.tar.gz -C /tmp/.potator-ipk/root/ .
	@echo 2.0 > /tmp/.potator-ipk/debian-binary
	@ar r potator.ipk /tmp/.potator-ipk/control.tar.gz /tmp/.potator-ipk/data.tar.gz /tmp/.potator-ipk/debian-binary
	
clean:
	rm -f $(PRGNAME)$(EXESUFFIX) *.o *.ipk 

