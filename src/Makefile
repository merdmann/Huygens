

main :: main.adb\
	vector_space.adb vector_space.ads \
	parameter_file.adb parameter_file.ads
	( cd .. && gnatmake -P heygens.gpr )

clean ::
	( cd .. && gnatclean -P heygens.gpr )
	rm -rf *.o *.ali main
