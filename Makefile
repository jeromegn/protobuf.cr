.PHONY: fixtures spec

fixtures:
	cd spec/fixtures && make clean all

spec: fixtures
	crystal spec
	