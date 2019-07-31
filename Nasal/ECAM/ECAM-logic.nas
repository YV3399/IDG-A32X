# A3XX Electronic Centralised Aircraft Monitoring System

# Copyright (c) 2019 Jonathan Redpath (legoboyvdlp)

# props.nas:

var dualFailNode = props.globals.initNode("/ECAM/dual-failure-enabled", 0, "BOOL");
var phaseNode    = props.globals.getNode("/ECAM/warning-phase", 1);
var leftMsgNode  = props.globals.getNode("/ECAM/left-msg", 1);
var apWarn       = props.globals.getNode("/it-autoflight/output/ap-warning", 1);
var athrWarn     = props.globals.getNode("/it-autoflight/output/athr-warning", 1);
var emerGen      = props.globals.getNode("/controls/electrical/switches/emer-gen", 1);

var fac1Node   = props.globals.getNode("/controls/fctl/fac1", 1);
var state1Node = props.globals.getNode("/engines/engine[0]/state", 1);
var state2Node = props.globals.getNode("/engines/engine[1]/state", 1);
var wowNode    = props.globals.getNode("/fdm/jsbsim/position/wow", 1);
var apu_rpm    = props.globals.getNode("/systems/apu/rpm", 1);
var wing_pb    = props.globals.getNode("/controls/switches/wing", 1);
var apumaster  = props.globals.getNode("/controls/APU/master", 1);
var apu_bleedSw   = props.globals.getNode("/controls/pneumatic/switches/bleedapu", 1);
var gear       = props.globals.getNode("/gear/gear-pos-norm", 1);
var cutoff1    = props.globals.getNode("/controls/engines/engine[0]/cutoff-switch", 1);
var cutoff2    = props.globals.getNode("/controls/engines/engine[1]/cutoff-switch", 1);
var engOpt     = props.globals.getNode("/options/eng", 1);
# local variables
var phaseVar = nil;
var dualFailFACActive = 1;

var messages_priority_3 = func {
	phaseVar = phaseNode.getValue();
	
	# FCTL
	if ((flap_not_zero.clearFlag == 0) and phaseVar == 6 and getprop("/controls/flight/flap-lever") != 0 and getprop("/instrumentation/altimeter/indicated-altitude-ft") > 22000) {
		flap_not_zero.active = 1;
	} else {
		ECAM_controller.warningReset(flap_not_zero);
	}
	
	# ENG DUAL FAIL
	
	if (phaseVar >= 5 and phaseVar <= 7 and dualFailNode.getBoolValue()) {
		dualFail.active = 1;
	} elsif (dualFailbatt.clearFlag == 1 or !dualFailNode.getBoolValue()) {
		ECAM_controller.warningReset(dualFail);
		
		dualFailFACActive = 1; # reset FAC local variable
	}
	
	if (dualFail.active == 1) {
		if (getprop("/controls/engines/engine-start-switch") != 2 and dualFailModeSel.clearFlag == 0) {
			dualFailModeSel.active = 1;
		} else {
			ECAM_controller.warningReset(dualFailModeSel);
		}
		
		if (getprop("/fdm/jsbsim/fcs/throttle-lever[0]") > 0.01 and getprop("/fdm/jsbsim/fcs/throttle-lever[1]") > 0.01 and dualFailLevers.clearFlag == 0) {
			dualFailLevers.active = 1;
		} else {
			ECAM_controller.warningReset(dualFailLevers);
		}
		
		if (engOpt.getValue() == "IAE" and dualFailRelightSPD.clearFlag == 0) {
			dualFailRelightSPD.active = 1;
		} else {
			ECAM_controller.warningReset(dualFailRelightSPD);
		}
		
		if (engOpt.getValue() != "IAE" and dualFailRelightSPDCFM.clearFlag == 0) {
			dualFailRelightSPDCFM.active = 1;
		} else {
			ECAM_controller.warningReset(dualFailRelightSPDCFM);
		}
		
		if (emerGen.getValue() == 0 and dualFailElec.clearFlag == 0) {
			dualFailElec.active = 1;
		} else {
			ECAM_controller.warningReset(dualFailElec);
		}
		
		if (dualFailRadio.clearFlag == 0) {
			dualFailRadio.active = 1;
		} else {
			ECAM_controller.warningReset(dualFailRadio);
		}
		
		if (dualFailFACActive == 1 and dualFailFAC.clearFlag == 0) {
			dualFailFAC.active = 1;
		} else {
			ECAM_controller.warningReset(dualFailFAC);
		}
		
		
		if (dualFailMasters.clearFlag == 0) {
			dualFailRelight.active = 1; # assumption
			dualFailMasters.active = 1;
		} else {
			ECAM_controller.warningReset(dualFailRelight);
			ECAM_controller.warningReset(dualFailMasters);
		}
		
		if (dualFailSPDGD.clearFlag == 0) {
			dualFailSuccess.active = 1; # assumption
			dualFailSPDGD.active = 1;
		} else {
			ECAM_controller.warningReset(dualFailSuccess);
			ECAM_controller.warningReset(dualFailSPDGD);
		}
		
		if (dualFailAPU.clearFlag == 0) {
			dualFailAPU.active = 1;
		} else {
			ECAM_controller.warningReset(dualFailAPU);
		}
		
		if (dualFailAPUwing.clearFlag == 0 and apu_rpm.getValue() > 94.9 and wing_pb.getBoolValue()) {
			dualFailAPUwing.active = 1;
		} else {
			ECAM_controller.warningReset(dualFailAPUwing);
		}
		
		if (dualFailAPUbleed.clearFlag == 0 and apu_rpm.getValue() > 94.9 and !apu_bleedSw.getBoolValue()) {
			dualFailAPUbleed.active = 1;
		} else {
			ECAM_controller.warningReset(dualFailAPUbleed);
		}
		
		if (dualFailMastersAPU.clearFlag == 0) {
			dualFailMastersAPU.active = 1;
		} else {
			ECAM_controller.warningReset(dualFailMastersAPU);
		}
		
		if (dualFailflap.clearFlag == 0) {
			dualFailAPPR.active = 1; # assumption
			dualFailflap.active = 1;
		} else {
			ECAM_controller.warningReset(dualFailAPPR);
			ECAM_controller.warningReset(dualFailflap);
		}
		
		if (dualFailcabin.clearFlag == 0) {
			dualFailcabin.active = 1;
		} else {
			ECAM_controller.warningReset(dualFailcabin);
		}
		
		if (dualFailrudd.clearFlag == 0) {
			dualFailrudd.active = 1;
		} else {
			ECAM_controller.warningReset(dualFailrudd);
		}
		
		if (dualFailgear.clearFlag == 0 and gear.getValue() != 1) {
			dualFail5000.active = 1; # according to doc
			dualFailgear.active = 1;
		} else {
			ECAM_controller.warningReset(dualFailgear);
			ECAM_controller.warningReset(dualFail5000);
		}
		
		if (dualFailfinalspeed.clearFlag == 0) {
			dualFailfinalspeed.active = 1;
		} else {
			ECAM_controller.warningReset(dualFailfinalspeed);
		}
		
		if (dualFailmasteroff.clearFlag == 0 and (!cutoff1.getBoolValue() or !cutoff2.getBoolValue())) {
			dualFailmasteroff.active = 1;
		} else {
			ECAM_controller.warningReset(dualFailmasteroff);
		}
		
		if (dualFailapuoff.clearFlag == 0 and apumaster.getBoolValue()) {
			dualFailapuoff.active = 1;
		} else {
			ECAM_controller.warningReset(dualFailapuoff);
		}
		
		if (dualFailevac.clearFlag == 0) {
			dualFailevac.active = 1;
		} else {
			ECAM_controller.warningReset(dualFailevac);
		}
		
		if (dualFailbatt.clearFlag == 0) { # elec power lost when batt goes off anyway I guess
			dualFailbatt.active = 1;
			dualFailtouch.active = 1;
		} else {
			ECAM_controller.warningReset(dualFailbatt);
			ECAM_controller.warningReset(dualFailtouch);
		}
	} else {
		ECAM_controller.warningReset(dualFailModeSel);
		ECAM_controller.warningReset(dualFailLevers);
		ECAM_controller.warningReset(dualFailRelightSPD);
		ECAM_controller.warningReset(dualFailRelightSPDCFM);
		ECAM_controller.warningReset(dualFailElec);
		ECAM_controller.warningReset(dualFailRadio);
		ECAM_controller.warningReset(dualFailFAC);
		ECAM_controller.warningReset(dualFailRelight);
		ECAM_controller.warningReset(dualFailMasters);
		ECAM_controller.warningReset(dualFailSuccess);
		ECAM_controller.warningReset(dualFailSPDGD);
		ECAM_controller.warningReset(dualFailAPU);
		ECAM_controller.warningReset(dualFailAPUwing);
		ECAM_controller.warningReset(dualFailAPUbleed);
		ECAM_controller.warningReset(dualFailMastersAPU);
		ECAM_controller.warningReset(dualFailAPPR);
		ECAM_controller.warningReset(dualFailflap);
		ECAM_controller.warningReset(dualFailcabin);
		ECAM_controller.warningReset(dualFailrudd);
		ECAM_controller.warningReset(dualFailgear);
		ECAM_controller.warningReset(dualFail5000);
		ECAM_controller.warningReset(dualFailfinalspeed);
		ECAM_controller.warningReset(dualFailmasteroff);
		ECAM_controller.warningReset(dualFailapuoff);
		ECAM_controller.warningReset(dualFailevac);
		ECAM_controller.warningReset(dualFailbatt);
		ECAM_controller.warningReset(dualFailtouch);
	}
	
	# ENG FIRE
	if ((eng1FireFlAgent2.clearFlag == 0 and getprop("/systems/fire/engine1/warning-active") == 1 and phaseVar >= 5 and phaseVar <= 7) or (eng1FireGnevacBat.clearFlag == 0 and getprop("/systems/fire/engine1/warning-active") == 1 and (phaseVar < 5 or phaseVar > 7))) {
		eng1Fire.active = 1;
	} else {
		ECAM_controller.warningReset(eng1Fire);
	}
	
	if ((eng2FireFlAgent2.clearFlag == 0 and getprop("/systems/fire/engine2/warning-active") == 1 and phaseVar >= 5 and phaseVar <= 7) or (eng2FireGnevacBat.clearFlag == 0 and getprop("/systems/fire/engine2/warning-active") == 1 and (phaseVar < 5 or phaseVar > 7))) {
		eng2Fire.active = 1;
	} else {
		ECAM_controller.warningReset(eng2Fire);
	}
	
	if (apuFireMaster.clearFlag == 0 and getprop("/systems/fire/apu/warning-active")) {
		apuFire.active = 1;
	} else {
		ECAM_controller.warningReset(apuFire);
	}
	
	if (eng1Fire.active == 1) {
		if (phaseVar >= 5 and phaseVar <= 7) {
			if (eng1FireFllever.clearFlag == 0 and getprop("/fdm/jsbsim/fcs/throttle-lever[0]") > 0.01) {
				eng1FireFllever.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireFllever);
			}
			
			if (eng1FireFlmaster.clearFlag == 0 and getprop("/controls/engines/engine[0]/cutoff-switch") == 0) {
				eng1FireFlmaster.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireFlmaster);
			}
			
			if (eng1FireFlPB.clearFlag == 0 and getprop("/controls/engines/engine[0]/fire-btn") == 0) {
				eng1FireFlPB.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireFlPB);
			}
			
			if (getprop("/systems/fire/engine1/agent1-timer") != 0 and getprop("/systems/fire/engine1/agent1-timer") != 99) {
				eng1FireFlAgent1Timer.msg = " -AGENT AFT " ~ getprop("/systems/fire/engine1/agent1-timer") ~ " S...DISCH";
			}
			
			if (eng1FireFlAgent1.clearFlag == 0 and getprop("/controls/engines/engine[0]/fire-btn") == 1 and !getprop("/systems/fire/engine1/disch1") and getprop("/systems/fire/engine1/agent1-timer") != 0 and getprop("/systems/fire/engine1/agent1-timer") != 99) {
				eng1FireFlAgent1Timer.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireFlAgent1Timer);
			}
			
			if (eng1FireFlAgent1.clearFlag == 0 and !getprop("/systems/fire/engine1/disch1") and (getprop("/systems/fire/engine1/agent1-timer") == 0 or getprop("/systems/fire/engine1/agent1-timer") == 99)) {
				eng1FireFlAgent1.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireFlAgent1);
			}
			
			if (eng1FireFlATC.clearFlag == 0) {
				eng1FireFlATC.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireFlATC);
			}
			
			if (getprop("/systems/fire/engine1/agent2-timer") != 0 and getprop("/systems/fire/engine1/agent2-timer") != 99) {
				eng1FireFl30Sec.msg = "•IF FIRE AFTER " ~ getprop("/systems/fire/engine1/agent2-timer") ~ " S:";
			}
			
			if (eng1FireFlAgent2.clearFlag == 0 and getprop("/systems/fire/engine1/disch1") and !getprop("/systems/fire/engine1/disch2") and getprop("/systems/fire/engine1/agent2-timer") > 0) {
				eng1FireFl30Sec.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireFl30Sec);
			}
			
			if (eng1FireFlAgent2.clearFlag == 0 and getprop("/systems/fire/engine1/disch1") and !getprop("/systems/fire/engine1/disch2")) {
				eng1FireFlAgent2.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireFlAgent2);
			}
		} else {
			ECAM_controller.warningReset(eng1FireFllever);
			ECAM_controller.warningReset(eng1FireFlmaster);
			ECAM_controller.warningReset(eng1FireFlPB);
			ECAM_controller.warningReset(eng1FireFlAgent1);
			ECAM_controller.warningReset(eng1FireFlATC);
			ECAM_controller.warningReset(eng1FireFl30Sec);
			ECAM_controller.warningReset(eng1FireFlAgent2);
		}
		
		if (phaseVar < 5 or phaseVar > 7) {
			if (eng1FireGnlever.clearFlag == 0 and getprop("/fdm/jsbsim/fcs/throttle-lever[0]") > 0.01 and getprop("/fdm/jsbsim/fcs/throttle-lever[1]") > 0.01) {
				eng1FireGnlever.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireGnlever);
			}
			
			if (eng1FireGnparkbrk.clearFlag == 0 and getprop("/controls/gear/brake-parking") == 0) { 
				eng1FireGnstopped.active = 1;
				eng1FireGnparkbrk.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireGnstopped);
				ECAM_controller.warningReset(eng1FireGnparkbrk);
			}
			
			if (eng1FireGnmaster.clearFlag == 0 and getprop("/controls/engines/engine[0]/cutoff-switch") == 0) {
				eng1FireGnmaster.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireGnmaster);
			}
			
			if (eng1FireGnPB.clearFlag == 0 and getprop("/controls/engines/engine[0]/fire-btn") == 0) {
				eng1FireGnPB.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireGnPB);
			}
			
			if (eng1FireGnAgent1.clearFlag == 0 and !getprop("/systems/fire/engine1/disch1")) {
				eng1FireGnAgent1.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireGnAgent1);
			}
			
			if (eng1FireGnAgent2.clearFlag == 0 and !getprop("/systems/fire/engine1/disch2")) {
				eng1FireGnAgent2.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireGnAgent2);
			}
			
			if (eng1FireGnmaster2.clearFlag == 0 and getprop("/controls/engines/engine[1]/cutoff-switch") == 0) {
				eng1FireGnmaster2.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireGnmaster2);
			}
			
			if (eng1FireGnATC.clearFlag == 0) {
				eng1FireGnATC.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireGnATC);
			}
			
			if (eng1FireGncrew.clearFlag == 0) {
				eng1FireGncrew.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireGncrew);
			}
			
			if (eng1FireGnevacSw.clearFlag == 0) {
				eng1FireGnevac.active = 1;
				eng1FireGnevacSw.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireGnevac);
				ECAM_controller.warningReset(eng1FireGnevacSw);
			}
			
			if (eng1FireGnevacApu.clearFlag == 0 and getprop("/controls/APU/master") and getprop("/systems/apu/rpm") > 99) {
				eng1FireGnevacApu.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireGnevacApu);
			}
			
			if (eng1FireGnevacBat.clearFlag == 0 and (getprop("/controls/electrical/switches/battery1") or getprop("/controls/electrical/switches/battery2"))) {
				eng1FireGnevacBat.active = 1;
			} else {
				ECAM_controller.warningReset(eng1FireGnevacBat);
			}
		} else {
			ECAM_controller.warningReset(eng1FireGnlever);
			ECAM_controller.warningReset(eng1FireGnstopped);
			ECAM_controller.warningReset(eng1FireGnparkbrk);
			ECAM_controller.warningReset(eng1FireGnmaster);
			ECAM_controller.warningReset(eng1FireGnPB);
			ECAM_controller.warningReset(eng1FireGnAgent1);
			ECAM_controller.warningReset(eng1FireGnAgent2);
			ECAM_controller.warningReset(eng1FireGnmaster2);
			ECAM_controller.warningReset(eng1FireGnATC);
			ECAM_controller.warningReset(eng1FireGncrew);
			ECAM_controller.warningReset(eng1FireGnevac);
			ECAM_controller.warningReset(eng1FireGnevacSw);
			ECAM_controller.warningReset(eng1FireGnevacApu);
			ECAM_controller.warningReset(eng1FireGnevacBat);
		}
	} else {
		ECAM_controller.warningReset(eng1FireFllever);
		ECAM_controller.warningReset(eng1FireFlmaster);
		ECAM_controller.warningReset(eng1FireFlPB);
		ECAM_controller.warningReset(eng1FireFlAgent1);
		ECAM_controller.warningReset(eng1FireFlATC);
		ECAM_controller.warningReset(eng1FireFl30Sec);
		ECAM_controller.warningReset(eng1FireFlAgent2);
		ECAM_controller.warningReset(eng1FireGnlever);
		ECAM_controller.warningReset(eng1FireGnstopped);
		ECAM_controller.warningReset(eng1FireGnparkbrk);
		ECAM_controller.warningReset(eng1FireGnmaster);
		ECAM_controller.warningReset(eng1FireGnPB);
		ECAM_controller.warningReset(eng1FireGnAgent1);
		ECAM_controller.warningReset(eng1FireGnAgent2);
		ECAM_controller.warningReset(eng1FireGnmaster2);
		ECAM_controller.warningReset(eng1FireGnATC);
		ECAM_controller.warningReset(eng1FireGncrew);
		ECAM_controller.warningReset(eng1FireGnevac);
		ECAM_controller.warningReset(eng1FireGnevacSw);
		ECAM_controller.warningReset(eng1FireGnevacApu);
		ECAM_controller.warningReset(eng1FireGnevacBat);
	}
	
	if (eng2Fire.active == 1) {
		if (phaseVar >= 5 and phaseVar <= 7) {
			if (eng2FireFllever.clearFlag == 0 and getprop("/fdm/jsbsim/fcs/throttle-lever[1]") > 0.01) {
				eng2FireFllever.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireFllever);
			}
			
			if (eng2FireFlmaster.clearFlag == 0 and getprop("/controls/engines/engine[1]/cutoff-switch") == 0) {
				eng2FireFlmaster.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireFlmaster);
			}
			
			if (eng2FireFlPB.clearFlag == 0 and getprop("/controls/engines/engine[1]/fire-btn") == 0) {
				eng2FireFlPB.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireFlPB);
			}
			
			if (getprop("/systems/fire/engine2/agent1-timer") != 0 and getprop("/systems/fire/engine2/agent1-timer") != 99) {
				eng2FireFlAgent1Timer.msg = " -AGENT AFT " ~ getprop("/systems/fire/engine2/agent1-timer") ~ " S...DISCH";
			}
			
			if (eng2FireFlAgent1.clearFlag == 0 and getprop("/controls/engines/engine[1]/fire-btn") == 1 and !getprop("/systems/fire/engine2/disch1") and getprop("/systems/fire/engine2agent1-timer") != 0 and getprop("/systems/fire/engine2/agent1-timer") != 99) {
				eng2FireFlAgent1Timer.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireFlAgent1Timer);
			}
			
			if (eng2FireFlAgent1.clearFlag == 0 and !getprop("/systems/fire/engine2/disch1") and (getprop("/systems/fire/engine2/agent1-timer") == 0 or getprop("/systems/fire/engine2/agent1-timer") == 99)) {
				eng2FireFlAgent1.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireFlAgent1);
			}
			
			if (eng2FireFlATC.clearFlag == 0) {
				eng2FireFlATC.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireFlATC);
			}
			
			if (getprop("/systems/fire/engine2/agent2-timer") != 0 and getprop("/systems/fire/engine2/agent2-timer") != 99) {
				eng2FireFl30Sec.msg = "•IF FIRE AFTER " ~ getprop("/systems/fire/engine2/agent2-timer") ~ " S:";
			}
			
			if (eng2FireFlAgent2.clearFlag == 0 and getprop("/systems/fire/engine2/disch1") and !getprop("/systems/fire/engine2/disch2") and getprop("/systems/fire/engine2/agent2-timer") > 0) {
				eng2FireFl30Sec.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireFl30Sec);
			}
			
			if (eng2FireFlAgent2.clearFlag == 0 and getprop("/systems/fire/engine2/disch1") and !getprop("/systems/fire/engine2/disch2")) {
				eng2FireFlAgent2.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireFlAgent2);
			}
		} else {
			ECAM_controller.warningReset(eng2FireFllever);
			ECAM_controller.warningReset(eng2FireFlmaster);
			ECAM_controller.warningReset(eng2FireFlPB);
			ECAM_controller.warningReset(eng2FireFlAgent1);
			ECAM_controller.warningReset(eng2FireFlATC);
			ECAM_controller.warningReset(eng2FireFl30Sec);
			ECAM_controller.warningReset(eng2FireFlAgent2);
		}
		
		if (phaseVar < 5 or phaseVar > 7) {
			if (eng2FireGnlever.clearFlag == 0 and getprop("/fdm/jsbsim/fcs/throttle-lever[0]") > 0.01 and getprop("/fdm/jsbsim/fcs/throttle-lever[1]") > 0.01) {
				eng2FireGnlever.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireGnlever);
			}
			
			if (eng2FireGnparkbrk.clearFlag == 0 and getprop("/controls/gear/brake-parking") == 0) { 
				eng2FireGnstopped.active = 1;
				eng2FireGnparkbrk.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireGnstopped);
				ECAM_controller.warningReset(eng2FireGnparkbrk);
			}
			
			if (eng2FireGnmaster.clearFlag == 0 and getprop("/controls/engines/engine[1]/cutoff-switch") == 0) {
				eng2FireGnmaster.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireGnmaster);
			}
			
			if (eng2FireGnPB.clearFlag == 0 and getprop("/controls/engines/engine[1]/fire-btn") == 0) {
				eng2FireGnPB.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireGnPB);
			}
			
			if (eng2FireGnAgent1.clearFlag == 0 and !getprop("/systems/fire/engine2/disch1")) {
				eng2FireGnAgent1.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireGnAgent1);
			}
			
			if (eng2FireGnAgent2.clearFlag == 0 and !getprop("/systems/fire/engine2/disch2")) {
				eng2FireGnAgent2.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireGnAgent2);
			}
			
			if (eng2FireGnmaster2.clearFlag == 0 and getprop("/controls/engines/engine[0]/cutoff-switch") == 0) {
				eng2FireGnmaster2.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireGnmaster2);
			}
			
			if (eng2FireGnATC.clearFlag == 0) {
				eng2FireGnATC.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireGnATC);
			}
			
			if (eng2FireGncrew.clearFlag == 0) {
				eng2FireGncrew.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireGncrew);
			}
			
			if (eng2FireGnevacSw.clearFlag == 0) {
				eng2FireGnevac.active = 1;
				eng2FireGnevacSw.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireGnevac);
				ECAM_controller.warningReset(eng2FireGnevacSw);
			}
			
			if (eng2FireGnevacApu.clearFlag == 0 and getprop("/controls/APU/master") and getprop("/systems/apu/rpm") > 99) {
				eng2FireGnevacApu.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireGnevacApu);
			}
			
			if (eng2FireGnevacBat.clearFlag == 0 and (getprop("/controls/electrical/switches/battery1") or getprop("/controls/electrical/switches/battery2"))) {
				eng2FireGnevacBat.active = 1;
			} else {
				ECAM_controller.warningReset(eng2FireGnevacBat);
			}
		} else {
			ECAM_controller.warningReset(eng2FireGnlever);
			ECAM_controller.warningReset(eng2FireGnstopped);
			ECAM_controller.warningReset(eng2FireGnparkbrk);
			ECAM_controller.warningReset(eng2FireGnmaster);
			ECAM_controller.warningReset(eng2FireGnPB);
			ECAM_controller.warningReset(eng2FireGnAgent1);
			ECAM_controller.warningReset(eng2FireGnAgent2);
			ECAM_controller.warningReset(eng2FireGnmaster2);
			ECAM_controller.warningReset(eng2FireGnATC);
			ECAM_controller.warningReset(eng2FireGncrew);
			ECAM_controller.warningReset(eng2FireGnevac);
			ECAM_controller.warningReset(eng2FireGnevacSw);
			ECAM_controller.warningReset(eng2FireGnevacApu);
			ECAM_controller.warningReset(eng2FireGnevacBat);
		}
	} else {
		ECAM_controller.warningReset(eng2FireFllever);
		ECAM_controller.warningReset(eng2FireFlmaster);
		ECAM_controller.warningReset(eng2FireFlPB);
		ECAM_controller.warningReset(eng2FireFlAgent1);
		ECAM_controller.warningReset(eng2FireFlATC);
		ECAM_controller.warningReset(eng2FireFl30Sec);
		ECAM_controller.warningReset(eng2FireFlAgent2);
		ECAM_controller.warningReset(eng2FireGnlever);
		ECAM_controller.warningReset(eng2FireGnstopped);
		ECAM_controller.warningReset(eng2FireGnparkbrk);
		ECAM_controller.warningReset(eng2FireGnmaster);
		ECAM_controller.warningReset(eng2FireGnPB);
		ECAM_controller.warningReset(eng2FireGnAgent1);
		ECAM_controller.warningReset(eng2FireGnAgent2);
		ECAM_controller.warningReset(eng2FireGnmaster2);
		ECAM_controller.warningReset(eng2FireGnATC);
		ECAM_controller.warningReset(eng2FireGncrew);
		ECAM_controller.warningReset(eng2FireGnevac);
		ECAM_controller.warningReset(eng2FireGnevacSw);
		ECAM_controller.warningReset(eng2FireGnevacApu);
		ECAM_controller.warningReset(eng2FireGnevacBat);
	}
	
	# APU Fire
	if (apuFire.active == 1) {
		if (apuFirePB.clearFlag == 0 and !getprop("/controls/APU/fire-btn")) {
			apuFirePB.active = 1;
		} else {
			ECAM_controller.warningReset(apuFirePB);
		}
		
		if (getprop("/systems/fire/apu/agent-timer") != 0 and getprop("/systems/fire/apu/agent-timer") != 99) {
			apuFireAgentTimer.msg = " -AGENT AFT " ~ getprop("/systems/fire/apu/agent-timer") ~ " S...DISCH";
		}
		
		if (apuFireAgent.clearFlag == 0 and getprop("/controls/APU/fire-btn") and !getprop("/systems/fire/apu/disch") and getprop("/systems/fire/apu/agent-timer") != 0) {
			apuFireAgentTimer.active = 1;
		} else {
			ECAM_controller.warningReset(apuFireAgentTimer);
		}
		
		if (apuFireAgent.clearFlag == 0 and getprop("/controls/APU/fire-btn") and !getprop("/systems/fire/apu/disch") and getprop("/systems/fire/apu/agent-timer") == 0) {
			apuFireAgent.active = 1;
		} else {
			ECAM_controller.warningReset(apuFireAgent);
		}
		
		if (apuFireMaster.clearFlag == 0 and getprop("/controls/APU/master")) {
			apuFireMaster.active = 1;
		} else {
			ECAM_controller.warningReset(apuFireMaster);
		}
	} else {
		ECAM_controller.warningReset(apuFirePB);
		ECAM_controller.warningReset(apuFireAgentTimer);
		ECAM_controller.warningReset(apuFireAgent);
		ECAM_controller.warningReset(apuFireMaster);
	}
	
	# CONFIG
	if ((slats_config.clearFlag == 0) and (getprop("/controls/flight/flap-lever") == 0 or getprop("/controls/flight/flap-lever")) == 4 and phaseVar >= 3 and phaseVar <= 4) {
		slats_config.active = 1;
		slats_config_1.active = 1;
	} else {
		ECAM_controller.warningReset(slats_config);
		ECAM_controller.warningReset(slats_config_1);
	}
	
	if ((flaps_config.clearFlag == 0) and (getprop("/controls/flight/flap-lever") == 0 or getprop("/controls/flight/flap-lever") == 4) and phaseVar >= 3 and phaseVar <= 4) {
		flaps_config.active = 1;
		flaps_config_1.active = 1;
	} else {
		ECAM_controller.warningReset(flaps_config);
		ECAM_controller.warningReset(flaps_config_1);
	}
	
	if ((spd_brk_config.clearFlag == 0) and getprop("/controls/flight/speedbrake") != 0 and phaseVar >= 3 and phaseVar <= 4) {
		spd_brk_config.active = 1;
		spd_brk_config_1.active = 1;
	} else {
		ECAM_controller.warningReset(spd_brk_config);
		ECAM_controller.warningReset(spd_brk_config_1);
	}
	
	if ((pitch_trim_config.clearFlag == 0) and (getprop("/fdm/jsbsim/hydraulics/elevator-trim/final-deg") > 1.75 or getprop("/fdm/jsbsim/hydraulics/elevator-trim/final-deg") < -3.65) and phaseVar >= 3 and phaseVar <= 4) {
		pitch_trim_config.active = 1;
		pitch_trim_config_1.active = 1;
	} else {
		ECAM_controller.warningReset(pitch_trim_config);
		ECAM_controller.warningReset(pitch_trim_config_1);
	}
	
	if ((rud_trim_config.clearFlag == 0) and (getprop("/fdm/jsbsim/hydraulics/rudder/trim-cmd-deg") < -3.55 or getprop("/fdm/jsbsim/hydraulics/rudder/trim-cmd-deg") > 3.55) and phaseVar >= 3 and phaseVar <= 4) {
		rud_trim_config.active = 1;
		rud_trim_config_1.active = 1;
	} else {
		ECAM_controller.warningReset(rud_trim_config);
		ECAM_controller.warningReset(rud_trim_config_1);
	}
	
	if ((park_brk_config.clearFlag == 0) and getprop("/controls/gear/brake-parking") == 1 and phaseVar >= 3 and phaseVar <= 4) {
		park_brk_config.active = 1;
	} else {
		ECAM_controller.warningReset(park_brk_config);
	}
	
	# AUTOFLT
	if ((ap_offw.clearFlag == 0) and apWarn.getValue() == 2) {
		ap_offw.active = 1;
	} else {
		ECAM_controller.warningReset(ap_offw);
		if (getprop("/it-autoflight/output/ap-warning") == 2) {
			setprop("/it-autoflight/output/ap-warning", 0);
			setprop("/ECAM/Lower/light/clr", 0);
			setprop("/ECAM/warnings/master-warning-light", 0);
		}
	}
	
	if ((athr_lock.clearFlag == 0) and phaseVar >= 5 and phaseVar <= 7 and getprop("/systems/thrust/thr-locked-alert") == 1) {
		if (getprop("/systems/thrust/thr-locked-flash") == 0) {
			athr_lock.msg = " ";
		} else {
			athr_lock.msg = msgSave
		}
		athr_lock.active = 1;
		athr_lock_1.active = 1;
	} else {
		ECAM_controller.warningReset(athr_lock);
		ECAM_controller.warningReset(athr_lock_1);
	}
	
	if ((athr_offw.clearFlag == 0) and athrWarn.getValue() == 2 and phaseVar != 4 and phaseVar != 8 and phaseVar != 10) {
		athr_offw.active = 1;
		athr_offw_1.active = 1;
	} else {
		ECAM_controller.warningReset(athr_offw);
		ECAM_controller.warningReset(athr_offw_1);
		if (getprop("/it-autoflight/output/athr-warning") == 2) {
			setprop("/it-autoflight/output/athr-warning", 0);
			setprop("/ECAM/Lower/light/clr", 0);
			setprop("/ECAM/warnings/master-caution-light", 0);
		}
	}
	
	if ((athr_lim.clearFlag == 0) and getprop("/it-autoflight/output/athr") == 1 and ((getprop("/systems/thrust/eng-out") != 1 and (getprop("/systems/thrust/state1") == "MAN" or getprop("/systems/thrust/state2") == "MAN")) or (getprop("/systems/thrust/eng-out") == 1 and (getprop("/systems/thrust/state1") == "MAN" or getprop("/systems/thrust/state2") == "MAN" or (getprop("/systems/thrust/state1") == "MAN THR" and getprop("/controls/engines/engine[0]/throttle-pos") <= 0.83) or (getprop("/systems/thrust/state2") == "MAN THR" and getprop("/controls/engines/engine[0]/throttle-pos") <= 0.83)))) and (phaseVar >= 5 and phaseVar <= 7)) {
		athr_lim.active = 1;
		athr_lim_1.active = 1;
	} else {
		ECAM_controller.warningReset(athr_lim);
		ECAM_controller.warningReset(athr_lim_1);
	}
	
	if (!systems.cargoTestBtn.getBoolValue()) {
		if (cargoSmokeFwd.clearFlag == 0 and systems.fwdCargoFireWarn.getBoolValue() and (getprop("/ECAM/warning-phase") <= 3 or getprop("/ECAM/warning-phase") >= 9 or getprop("/ECAM/warning-phase") == 6)) {
			cargoSmokeFwd.active = 1;
		} elsif (cargoSmokeFwd.clearFlag == 1 or systems.cargoTestBtnOff.getBoolValue()) {
			ECAM_controller.warningReset(cargoSmokeFwd);
			cargoSmokeFwd.hasSubmsg = 1;
		}
		
		if (cargoSmokeFwdAgent.clearFlag == 0 and cargoSmokeFwd.active == 1 and !getprop("/systems/fire/cargo/disch")) {
			cargoSmokeFwdAgent.active = 1;
		} else {
			ECAM_controller.warningReset(cargoSmokeFwdAgent);
			cargoSmokeFwd.hasSubmsg = 0;
		}

		if (cargoSmokeAft.clearFlag == 0 and systems.aftCargoFireWarn.getBoolValue() and (getprop("/ECAM/warning-phase") <= 3 or getprop("/ECAM/warning-phase") >= 9 or getprop("/ECAM/warning-phase") == 6)) {
			cargoSmokeAft.active = 1;
		} elsif (cargoSmokeAft.clearFlag == 1 or systems.cargoTestBtnOff.getBoolValue()) {
			ECAM_controller.warningReset(cargoSmokeAft);
			cargoSmokeAft.hasSubmsg = 1;
			systems.cargoTestBtnOff.setBoolValue(0);
		}
		
		if (cargoSmokeAftAgent.clearFlag == 0 and cargoSmokeAft.active == 1 and !getprop("/systems/fire/cargo/disch")) {
			cargoSmokeAftAgent.active = 1;
		} else {
			ECAM_controller.warningReset(cargoSmokeAftAgent);
			cargoSmokeAft.hasSubmsg = 0;
		}
	} else {
		if (systems.aftCargoFireWarn.getBoolValue()) {
			cargoSmokeFwd.active = 1;
			cargoSmokeFwdAgent.active = 1;
			cargoSmokeAft.active = 1;
			cargoSmokeAftAgent.active = 1;
		} else {
			ECAM_controller.warningReset(cargoSmokeFwd);
			ECAM_controller.warningReset(cargoSmokeFwdAgent);
			ECAM_controller.warningReset(cargoSmokeAft);
			ECAM_controller.warningReset(cargoSmokeAftAgent);
		}
	}
}

var messages_priority_2 = func {
	if (apuEmerShutdown.clearFlag == 0 and systems.apuEmerShutdown.getBoolValue() and !getprop("/systems/fire/apu/warning-active") and (getprop("/ECAM/warning-phase") == 6 or getprop("/ECAM/warning-phase") >= 9 or getprop("/ECAM/warning-phase") <= 2)) {
		apuEmerShutdown.active = 1;
	} elsif (apuEmerShutdown.clearFlag == 1) {
		ECAM_controller.warningReset(apuEmerShutdown);
		apuEmerShutdown.hasSubmsg = 1;
	}
	
	if (apuEmerShutdownMast.clearFlag == 0 and getprop("/controls/APU/master") and apuEmerShutdown.active == 1) {
		apuEmerShutdownMast.active = 1;
	} else {
		ECAM_controller.warningReset(apuEmerShutdownMast);
		apuEmerShutdown.hasSubmsg = 0;
	}
	
	if (eng1FireDetFault.clearFlag == 0 and (systems.engFireDetectorUnits.vector[0].condition == 0 or (systems.engFireDetectorUnits.vector[0].loopOne == 9 and systems.engFireDetectorUnits.vector[0].loopTwo == 9 and systems.eng1Inop.getBoolValue())) and (getprop("/ECAM/warning-phase") == 6 or getprop("/ECAM/warning-phase") >= 9 or getprop("/ECAM/warning-phase") <= 2)) {
		eng1FireDetFault.active = 1;
	} else {
		ECAM_controller.warningReset(eng1FireDetFault);
	}
	
	if (eng1LoopAFault.clearFlag == 0 and systems.engFireDetectorUnits.vector[0].loopOne == 9 and systems.engFireDetectorUnits.vector[0].loopTwo != 9 and !systems.eng1Inop.getBoolValue() and (getprop("/ECAM/warning-phase") == 6 or getprop("/ECAM/warning-phase") >= 9 or getprop("/ECAM/warning-phase") <= 2)) {
		eng1LoopAFault.active = 1;
	} else {
		ECAM_controller.warningReset(eng1LoopAFault);
	}
	
	if (eng1LoopBFault.clearFlag == 0 and systems.engFireDetectorUnits.vector[0].loopOne != 9 and systems.engFireDetectorUnits.vector[0].loopTwo == 9 and !systems.eng1Inop.getBoolValue() and (getprop("/ECAM/warning-phase") == 6 or getprop("/ECAM/warning-phase") >= 9 or getprop("/ECAM/warning-phase") <= 2)) {
		eng1LoopBFault.active = 1;
	} else {
		ECAM_controller.warningReset(eng1LoopBFault);
	}
	
	if (eng2FireDetFault.clearFlag == 0 and (systems.engFireDetectorUnits.vector[1].condition == 0 or (systems.engFireDetectorUnits.vector[1].loopOne == 9 and systems.engFireDetectorUnits.vector[1].loopTwo == 9 and systems.eng2Inop.getBoolValue())) and (getprop("/ECAM/warning-phase") == 6 or getprop("/ECAM/warning-phase") >= 9 or getprop("/ECAM/warning-phase") <= 2)) {
		eng2FireDetFault.active = 1;
	} else {
		ECAM_controller.warningReset(eng2FireDetFault);
	}
	
	if (eng2LoopAFault.clearFlag == 0 and systems.engFireDetectorUnits.vector[1].loopOne == 9 and systems.engFireDetectorUnits.vector[1].loopTwo != 9 and !systems.eng2Inop.getBoolValue() and (getprop("/ECAM/warning-phase") == 6 or getprop("/ECAM/warning-phase") >= 9 or getprop("/ECAM/warning-phase") <= 2)) {
		eng2LoopAFault.active = 1;
	} else {
		ECAM_controller.warningReset(eng2LoopAFault);
	}
	
	if (eng2LoopBFault.clearFlag == 0 and systems.engFireDetectorUnits.vector[1].loopOne != 9 and systems.engFireDetectorUnits.vector[1].loopTwo == 9 and !systems.eng2Inop.getBoolValue() and (getprop("/ECAM/warning-phase") == 6 or getprop("/ECAM/warning-phase") >= 9 or getprop("/ECAM/warning-phase") <= 2)) {
		eng2LoopBFault.active = 1;
	} else {
		ECAM_controller.warningReset(eng2LoopBFault);
	}
	
	if (apuFireDetFault.clearFlag == 0 and (systems.engFireDetectorUnits.vector[2].condition == 0 or (systems.engFireDetectorUnits.vector[2].loopOne == 9 and systems.engFireDetectorUnits.vector[2].loopTwo == 9 and systems.apuInop.getBoolValue())) and (getprop("/ECAM/warning-phase") == 6 or getprop("/ECAM/warning-phase") >= 9 or getprop("/ECAM/warning-phase") <= 2)) {
		apuFireDetFault.active = 1;
	} else {
		ECAM_controller.warningReset(apuFireDetFault);
	}
	
	if (apuLoopAFault.clearFlag == 0 and systems.engFireDetectorUnits.vector[2].loopOne == 9 and systems.engFireDetectorUnits.vector[2].loopTwo != 9 and !systems.apuInop.getBoolValue() and (getprop("/ECAM/warning-phase") == 6 or getprop("/ECAM/warning-phase") >= 9 or getprop("/ECAM/warning-phase") <= 2)) {
		apuLoopAFault.active = 1;
	} else {
		ECAM_controller.warningReset(apuLoopAFault);
	}
	
	if (apuLoopBFault.clearFlag == 0 and systems.engFireDetectorUnits.vector[2].loopOne != 9 and systems.engFireDetectorUnits.vector[2].loopTwo == 9 and !systems.apuInop.getBoolValue() and (getprop("/ECAM/warning-phase") == 6 or getprop("/ECAM/warning-phase") >= 9 or getprop("/ECAM/warning-phase") <= 2)) {
		apuLoopBFault.active = 1;
	} else {
		ECAM_controller.warningReset(apuLoopBFault);
	}
	
	if (crgAftFireDetFault.clearFlag == 0 and (systems.cargoSmokeDetectorUnits.vector[0].condition == 0 or systems.cargoSmokeDetectorUnits.vector[1].condition == 0) and (getprop("/ECAM/warning-phase") == 6 or getprop("/ECAM/warning-phase") >= 9 or getprop("/ECAM/warning-phase") <= 2)) {
		crgAftFireDetFault.active = 1;
	} else {
		ECAM_controller.warningReset(crgAftFireDetFault);
	}
	
	if (crgFwdFireDetFault.clearFlag == 0 and systems.cargoSmokeDetectorUnits.vector[2].condition == 0 and (getprop("/ECAM/warning-phase") == 6 or getprop("/ECAM/warning-phase") >= 9 or getprop("/ECAM/warning-phase") <= 2)) {
		crgFwdFireDetFault.active = 1;
	} else {
		ECAM_controller.warningReset(crgFwdFireDetFault);
	}
}

var messages_priority_1 = func {}
var messages_priority_0 = func {}

var messages_memo = func {
	phaseVar = phaseNode.getValue();
	if (getprop("/services/fuel-truck/enable") == 1 and leftMsgNode.getValue() != "TO-MEMO" and leftMsgNode.getValue() != "LDG-MEMO") {
		refuelg.active = 1;
	} else {
		refuelg.active = 0;
	}
	
	if (getprop("/controls/flight/speedbrake-arm") == 1) {
		gnd_splrs.active = 1;
	} else {
		gnd_splrs.active = 0;
	}
	
	if (getprop("/controls/lighting/seatbelt-sign") == 1 and leftMsgNode.getValue() != "TO-MEMO" and leftMsgNode.getValue() != "LDG-MEMO") {
		seatbelts.active = 1;
	} else {
		seatbelts.active = 0;
	}
	
	if (getprop("/controls/lighting/no-smoking-sign") == 1 and leftMsgNode.getValue() != "TO-MEMO" and leftMsgNode.getValue() != "LDG-MEMO") { # should go off after takeoff assuming switch is in auto due to old logic from the days when smoking was allowed!
		nosmoke.active = 1;
	} else {
		nosmoke.active = 0;
	}

	if (getprop("/controls/lighting/strobe") == 0 and getprop("/gear/gear[1]/wow") == 0 and leftMsgNode.getValue() != "TO-MEMO" and leftMsgNode.getValue() != "LDG-MEMO") { # todo: use gear branch properties
		strobe_lt_off.active = 1;
	} else {
		strobe_lt_off.active = 0;
	}

	if (getprop("/consumables/fuel/total-fuel-lbs") < 6000 and leftMsgNode.getValue() != "TO-MEMO" and leftMsgNode.getValue() != "LDG-MEMO") { # assuming US short ton 2000lb
		fob_3T.active = 1;
	} else {
		fob_3T.active = 0;
	}
	
	if (getprop("instrumentation/mk-viii/inputs/discretes/momentary-flap-all-override") == 1) {
		gpws_flap_mode_off.active = 1;
	} else {
		gpws_flap_mode_off.active = 0;
	}
	
}

var messages_right_memo = func {
	phaseVar = phaseNode.getValue();
	if (phaseVar >= 3 and phaseVar <= 5) {
		to_inhibit.active = 1;
	} else {
		to_inhibit.active = 0;
	}
	
	if (phaseVar >= 7 and phaseVar <= 7) {
		ldg_inhibit.active = 1;
	} else {
		ldg_inhibit.active = 0;
	}
	
	if ((getprop("/gear/gear[1]/wow") == 0) and (getprop("/systems/fire/engine1/warning-active") == 1 or getprop("/systems/fire/engine2/warning-active") == 1 or getprop("/systems/fire/apu/warning-active") == 1 or getprop("/systems/failures/cargo-aft-fire") == 1 or getprop("/systems/failures/cargo-fwd-fire") == 1) or (((getprop("/systems/hydraulic/green-psi") < 1500 and getprop("/engines/engine[0]/state") == 3) and (getprop("/systems/hydraulic/yellow-psi") < 1500 and getprop("/engines/engine[1]/state") == 3)) or ((getprop("/systems/hydraulic/green-psi") < 1500 or getprop("/systems/hydraulic/yellow-psi") < 1500) and getprop("/engines/engine[0]/state") == 3 and getprop("/engines/engine[1]/state") == 3) and phaseVar >= 3 and phaseVar <= 8)) {
		# todo: emer elec
		land_asap_r.active = 1;
	} else {
		land_asap_r.active = 0;
	}
	
	if (land_asap_r.active == 0 and getprop("/gear/gear[1]/wow") == 0 and ((getprop("/fdm/jsbsim/propulsion/tank[0]/contents-lbs") < 1650 and getprop("/fdm/jsbsim/propulsion/tank[1]/contents-lbs") < 1650) or ((getprop("/systems/electrical/bus/dc2") < 25 and (getprop("/systems/failures/elac1") == 1 or getprop("/systems/failures/sec1") == 1)) or (getprop("/systems/hydraulic/green-psi") < 1500 and (getprop("/systems/failures/elac1") == 1 and getprop("/systems/failures/sec1") == 1)) or (getprop("/systems/hydraulic/yellow-psi") < 1500 and (getprop("/systems/failures/elac1") == 1 and getprop("/systems/failures/sec1") == 1)) or (getprop("/systems/hydraulic/blue-psi") < 1500 and (getprop("/systems/failures/elac2") == 1 and getprop("/systems/failures/sec2") == 1))) or (phaseVar >= 3 and phaseVar <= 8 and (getprop("/engines/engine[0]/state") != 3 or getprop("/engines/engine[1]/state") != 3)))) {
		land_asap_a.active = 1;
	} else {
		land_asap_a.active = 0;
	}
	
	if (libraries.ap_active == 1 and apWarn.getValue() == 1) {
		ap_off.active = 1;
	} else {
		ap_off.active = 0;
	}
	
	if (libraries.athr_active == 1 and athrWarn.getValue() == 1) {
		athr_off.active = 1;
	} else {
		athr_off.active = 0;
	}
	
	if ((phaseVar >= 2 and phaseVar <= 7) and getprop("controls/flight/speedbrake") != 0) {
		spd_brk.active = 1;
	} else {
		spd_brk.active = 0;
	}
	
	if (getprop("/systems/thrust/state1") == "IDLE" and getprop("/systems/thrust/state2") == "IDLE" and phaseVar >= 6 and phaseVar <= 7) {
		spd_brk.colour = "g";
	} else if ((phaseVar >= 2 and phaseVar <= 5) or ((getprop("/systems/thrust/state1") != "IDLE" or getprop("/systems/thrust/state2") != "IDLE") and (phaseVar >= 6 and phaseVar <= 7))) {
		spd_brk.colour = "a";
	}
	
	if (getprop("/controls/gear/brake-parking") == 1 and phaseVar != 3) {
		park_brk.active = 1;
	} else {
		park_brk.active = 0;
	}
	if (phaseVar >= 4 and phaseVar <= 8) {
		park_brk.colour = "a";
	} else {
		park_brk.colour = "g";
	}
	
	if (getprop("/controls/hydraulic/ptu") == 1 and ((getprop("/systems/hydraulic/yellow-psi") < 1450 and getprop("/systems/hydraulic/green-psi") > 1450 and getprop("/controls/hydraulic/elec-pump-yellow") == 0) or (getprop("/systems/hydraulic/yellow-psi") > 1450 and getprop("/systems/hydraulic/green-psi") < 1450))) {
		ptu.active = 1;
	} else {
		ptu.active = 0;
	}
	
	if (getprop("/controls/hydraulic/rat-deployed") == 1) {
		rat.active = 1;
	} else {
		rat.active = 0;
	}
	
	if (phaseVar >= 1 and phaseVar <= 2) {
		rat.colour = "a";
	} else {
		rat.colour = "g";
	}
	
	if (getprop("/sim/model/autopush/enabled") == 1) { # this message is only on when towing - not when disc with switch
		nw_strg_disc.active = 1;
	} else {
		nw_strg_disc.active = 0;
	}
	
	if (getprop("/engines/engine[0]/state") == 3 or getprop("/engines/engine[1]/state") == 3) {
		nw_strg_disc.colour = "a";
	} else {
		nw_strg_disc.colour = "g";
	}
	
	if (getprop("/controls/electrical/switches/emer-gen") == 1 and getprop("/controls/hydraulic/rat-deployed") == 1 and getprop("/gear/gear[1]/wow") == 0) {
		emer_gen.active = 1;
	} else {
		emer_gen.active = 0;
	}
	
	if (getprop("/controls/pneumatic/switches/ram-air") == 1) {
		ram_air.active = 1;
	} else {
		ram_air.active = 0;
	}

	if (getprop("/controls/engines/engine[0]/igniter-a") == 1 or getprop("/controls/engines/engine[0]/igniter-b") == 1 or getprop("/controls/engines/engine[1]/igniter-a") == 1 or getprop("/controls/engines/engine[1]/igniter-b") == 1) {
		ignition.active = 1;
	} else {
		ignition.active = 0;
	}
	
	if (getprop("/controls/pneumatic/switches/bleedapu") == 1 and getprop("/systems/apu/rpm") >= 95) {
		apu_bleed.active = 1;
	} else {
		apu_bleed.active = 0;
	}

	if (apu_bleed.active == 0 and getprop("/systems/apu/rpm") >= 95) {
		apu_avail.active = 1;
	} else {
		apu_avail.active = 0;
	}

	if (getprop("/controls/lighting/landing-lights[1]") > 0 or getprop("/controls/lighting/landing-lights[2]") > 0) {
		ldg_lt.active = 1;
	} else {
		ldg_lt.active = 0;
	}

	if (getprop("/controls/switches/leng") == 1 or getprop("/controls/switches/reng") == 1 or getprop("/systems/electrical/bus/dc1") == 0 or getprop("/systems/electrical/bus/dc2") == 0) {
		eng_aice.active = 1;
	} else {
		eng_aice.active = 0;
	}
	
	if (getprop("/controls/switches/wing") == 1) {
		wing_aice.active = 1;
	} else {
		wing_aice.active = 0;
	}
	
	if (getprop("/instrumentation/comm[2]/frequencies/selected-mhz") != 0 and (phaseVar == 1 or phaseVar == 2 or phaseVar == 6 or phaseVar == 9 or phaseVar == 10)) {
		vhf3_voice.active = 1;
	} else {
		vhf3_voice.active = 0;
	}
	if (getprop("/controls/autobrake/mode") == 1 and (phaseVar == 7 or phaseVar == 8)) {
		auto_brk_lo.active = 1;
	} else {
		auto_brk_lo.active = 0;
	}

	if (getprop("/controls/autobrake/mode") == 2 and (phaseVar == 7 or phaseVar == 8)) {
		auto_brk_med.active = 1;
	} else {
		auto_brk_med.active = 0;
	}

	if (getprop("/controls/autobrake/mode") == 3 and (phaseVar == 7 or phaseVar == 8)) {
		auto_brk_max.active = 1;
	} else {
		auto_brk_max.active = 0;
	}
	
	if (getprop("/systems/fuel/x-feed") == 1 and getprop("controls/fuel/x-feed") == 1) {
		fuelx.active = 1;
	} else {
		fuelx.active = 0;
	}
	
	if (phaseVar >= 3 and phaseVar <= 5) {
		fuelx.colour = "a";
	} else {
		fuelx.colour = "g";
	}
	
	if (getprop("/instrumentation/mk-viii/inputs/discretes/momentary-flap-3-override") == 1) { # todo: emer elec
		gpws_flap3.active = 1;
	} else {
		gpws_flap3.active = 0;
	}
	
	if (phaseVar >= 2 and phaseVar <= 9 and getprop("/systems/fuel/only-use-ctr-tank") == 1 and getprop("/systems/electrical/bus/ac1") >= 115 and getprop("/systems/electrical/bus/ac2") >= 115) {
		ctr_tk_feedg.active = 1;
	} else {
		ctr_tk_feedg.active = 0;
	}
}

# Listeners
setlistener("/controls/fctl/fac1", func() {
	if (dualFail.active == 0) { return; }
	
	if (fac1Node.getBoolValue()) {
		dualFailFACActive = 0;
	} else {
		dualFailFACActive = 1;
	}
}, 0, 0);

setlistener("/engines/engine[0]/state", func() {
	if ((state1Node.getValue() != 3 and state2Node.getValue() != 3) and wowNode.getValue() == 0) {
		dualFailNode.setBoolValue(1);
	} else {
		dualFailNode.setBoolValue(0);
	}
}, 0, 0);

setlistener("/engines/engine[1]/state", func() {
	if ((state1Node.getValue() != 3 and state2Node.getValue() != 3) and wowNode.getValue() == 0) {
		dualFailNode.setBoolValue(1);
	} else {
		dualFailNode.setBoolValue(0);
	}
}, 0, 0);