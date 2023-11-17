beectl : src/beectl.cr src/beedefs.cr
	crystal build --no-color src/beectl.cr

.PHONY: test
test :
	crystal spec --no-color
