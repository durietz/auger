BIN = $(GRASP)/bin

TARGETS  = install
$(TARGETS):
	pp5.18 -o $(BIN)/auger_cud auger_cud.pl ; \
	pp5.18 -o $(BIN)/auger_cud_rdr3 auger_cud_rdr3.pl ; \
	pp5.18 -o $(BIN)/auger_cud_rdr3_printprogress auger_cud_rdr3_printprogress.pl ; \
	pp5.18 -o $(BIN)/auger auger.pl ; \
	pp5.18 -o $(BIN)/trans_cud trans_cud.pl ; \
	pp5.18 -o $(BIN)/trans_cud_rtransition trans_cud_rtransition.pl ; \
	pp5.18 -o $(BIN)/trans_cud_rtransition_rdr trans_cud_rtransition_rdr.pl ; \
	pp5.18 -o $(BIN)/trans_cud_rtransition_rdr_printprogress trans_cud_rtransition_rdr_printprogress.pl ; \
	pp5.18 -o $(BIN)/diagnostics diagnostics.pl ; \
	pp5.18 -o $(BIN)/makeinput makeinput.pl ; \
	pp5.18 -o $(BIN)/eadlformat eadlformat.pl ; \
	pp5.18 -o $(BIN)/augertable augertable.pl ; \
	pp5.18 -o $(BIN)/radtable radtable.pl ; \
	pp5.18 -o $(BIN)/eadlreplace eadlreplace.pl ; \
	pp5.18 -o $(BIN)/readtrans_rdr readtrans_rdr.pl ; \	

clean:
	-rm -f $(BIN)/auger_cud $(BIN)/auger_cud_rdr3 $(BIN)/auger_cud_rdr3_printprogress $(BIN)/auger $(BIN)/trans_cud $(BIN)/trans_cud_rtransition $(BIN)/trans_cud_rtransition_rdr $(BIN)/trans_cud_rtransition_rdr_printprogress $(BIN)/diagnostics $(BIN)/makeinput $(BIN)/eadlformat $(BIN)/augertable $(BIN)/radtable $(BIN)/eadlreplace
