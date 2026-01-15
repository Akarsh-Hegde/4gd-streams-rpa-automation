// SOP Flowchart Data for ReactFlow
export const initialNodes = [
  // Start
  {
    id: "start",
    type: "input",
    position: { x: 250, y: 0 },
    data: { label: "Start: New Submission Received" },
    style: { background: "#90EE90", border: "2px solid #333" },
  },

  // ImageRight Process
  {
    id: "openIR",
    position: { x: 250, y: 80 },
    data: { label: "Open ImageRight Clearance Desk" },
  },
  {
    id: "establishRDC",
    position: { x: 250, y: 160 },
    data: { label: "RDC Connected?" },
    style: { background: "#FFE4B5" },
  },
  {
    id: "connectRDC",
    position: { x: 100, y: 240 },
    data: { label: "Establish RDC Connection" },
  },
  {
    id: "fetchClearance",
    position: { x: 250, y: 320 },
    data: { label: "Fetch Clearance Box" },
  },

  // Priority
  {
    id: "checkEffDate",
    position: { x: 250, y: 400 },
    data: { label: "Note Effective Date & Priority" },
  },
  {
    id: "prioritizeFiles",
    position: { x: 250, y: 480 },
    data: { label: "Check Priority" },
    style: { background: "#FFE4B5" },
  },
  {
    id: "setPriority1",
    position: { x: 100, y: 560 },
    data: { label: "Set Priority 1 - Red (Insty ≤14 days)" },
  },
  {
    id: "setPriority5",
    position: { x: 400, y: 560 },
    data: { label: "Set Priority 5 (Regular)" },
  },
  {
    id: "sortByDate",
    position: { x: 250, y: 640 },
    data: { label: "Sort by Effective Date Ascending" },
  },

  // Open Submission
  {
    id: "openSubmission",
    position: { x: 250, y: 720 },
    data: { label: "Open Submission" },
  },
  {
    id: "checkEffDateApp",
    position: { x: 250, y: 800 },
    data: { label: "Check Application for Effective Date" },
  },
  {
    id: "markEffDate",
    position: { x: 250, y: 880 },
    data: { label: "Mark Effective Date in ImageRight" },
  },
  {
    id: "autoProcessCheck",
    position: { x: 250, y: 960 },
    data: { label: "Auto Process Available?" },
    style: { background: "#FFE4B5" },
  },
  {
    id: "autoProcess",
    position: { x: 100, y: 1040 },
    data: { label: "Click Auto Process" },
    style: { background: "#98FB98" },
  },
  {
    id: "manualOpen",
    position: { x: 400, y: 1040 },
    data: { label: "Manual: Double Click to Open" },
  },
  {
    id: "orderPages",
    position: { x: 250, y: 1120 },
    data: { label: "Order & Label Pages in IR" },
  },
  {
    id: "labelPages",
    position: { x: 250, y: 1200 },
    data: { label: "Label Main Pages: INFO, LOBs" },
  },
  {
    id: "moveCorrespondence",
    position: { x: 250, y: 1280 },
    data: { label: "Move Correspondence to Folders" },
  },

  // DNQ Check
  {
    id: "checkDNQ",
    position: { x: 250, y: 1360 },
    data: { label: "Check Do Not Quote List" },
  },
  {
    id: "onDNQList",
    position: { x: 250, y: 1440 },
    data: { label: "Insured on DNQ List?" },
    style: { background: "#FF6347", color: "#fff" },
  },
  {
    id: "dnqProcess",
    position: { x: 50, y: 1520 },
    data: {
      label:
        "Add File Note - DNQ\nEmail UW & Managers\nLeave in Submitted Status",
    },
    style: { background: "#FFA500" },
  },
  {
    id: "endDNQ",
    type: "output",
    position: { x: 50, y: 1620 },
    data: { label: "End - DNQ" },
    style: { background: "#FFB6C1", border: "2px solid #333" },
  },

  // IMS Search
  {
    id: "searchIMS",
    position: { x: 400, y: 1520 },
    data: { label: "Search Insured in IMS" },
  },
  {
    id: "crossReference",
    position: { x: 400, y: 1600 },
    data: { label: "Cross-Reference:\n- Name/DBA\n- Phone\n- Address\n- FEIN" },
  },
  {
    id: "foundInIMS",
    position: { x: 400, y: 1720 },
    data: { label: "Found in IMS?" },
    style: { background: "#FFE4B5" },
  },

  // Create New Insured
  {
    id: "createInsured",
    position: { x: 600, y: 1800 },
    data: { label: "Create New Insured" },
  },
  {
    id: "enterInsuredInfo",
    position: { x: 600, y: 1880 },
    data: {
      label: "Enter Insured Info:\n- Business Name\n- FEIN\n- Address\n- Phone",
    },
  },
  {
    id: "enterContactInfo",
    position: { x: 600, y: 1980 },
    data: { label: "Enter Contact Info from Page 2" },
  },

  // Submission Type Check
  {
    id: "checkSubmissionType",
    position: { x: 200, y: 1800 },
    data: { label: "Submission Type?" },
    style: { background: "#FFE4B5" },
  },
  {
    id: "checkControlNum",
    position: { x: 50, y: 1900 },
    data: { label: "Control # Generated?" },
    style: { background: "#FFE4B5" },
  },
  {
    id: "rescheduleRenewal",
    position: { x: 50, y: 2000 },
    data: {
      label: "Change Description: Eff Date-PDG RWL\nReschedule to UW_RENEWALS",
    },
  },
  {
    id: "deletePhotos",
    position: { x: 50, y: 2100 },
    data: { label: "Delete Photos from Photos Folder" },
  },

  // Create Submission
  {
    id: "createSubmission",
    position: { x: 400, y: 2080 },
    data: { label: "Create New Submission" },
  },
  {
    id: "enterProducer",
    position: { x: 400, y: 2160 },
    data: { label: "Enter Producer By Contact" },
  },
  {
    id: "producerFound",
    position: { x: 400, y: 2240 },
    data: { label: "Producer in IMS?" },
    style: { background: "#FFE4B5" },
  },

  // Producer Setup
  {
    id: "addProducer",
    position: { x: 600, y: 2320 },
    data: { label: "Add Producer to IMS" },
  },
  {
    id: "checkAgency",
    position: { x: 600, y: 2400 },
    data: { label: "Agency in IMS?" },
    style: { background: "#FFE4B5" },
  },
  {
    id: "contactMarketing",
    position: { x: 750, y: 2480 },
    data: { label: "Email Marketing for Agency Setup" },
  },
  {
    id: "waitForSetup",
    position: { x: 750, y: 2560 },
    data: { label: "Wait for Marketing Response" },
  },
  {
    id: "addToAgency",
    position: { x: 450, y: 2480 },
    data: { label: "Add Producer to Agency" },
  },
  {
    id: "selectProducer",
    position: { x: 400, y: 2640 },
    data: { label: "Select Correct Producer & Location" },
  },

  // UW Assignment
  {
    id: "assignUW",
    position: { x: 400, y: 2720 },
    data: { label: "Assign Underwriter from Producer List" },
  },
  {
    id: "selectQuoteType",
    position: { x: 400, y: 2800 },
    data: { label: "Select Full Quote" },
  },
  {
    id: "enterQuoteInfo",
    position: { x: 400, y: 2880 },
    data: { label: "Enter Quote Information" },
  },
  {
    id: "setQuotingOffice",
    position: { x: 400, y: 2960 },
    data: { label: "Set Quoting Office: RISCOM LLC" },
  },

  // LOB Selection
  {
    id: "selectLOB",
    position: { x: 400, y: 3040 },
    data: { label: "Select Line of Business" },
    style: { background: "#FFE4B5" },
  },
  {
    id: "setMGALOB",
    position: { x: 100, y: 3140 },
    data: { label: "Set LOB: BA/GL/CP/IM/Package (MGA)" },
  },
  {
    id: "setWholesaleLOB",
    position: { x: 250, y: 3140 },
    data: { label: "Set LOB: Wholesale" },
  },
  {
    id: "setTruckingLOB",
    position: { x: 400, y: 3140 },
    data: { label: "Set LOB: Trucking BA/Package" },
  },
  {
    id: "setGarageLOB",
    position: { x: 550, y: 3140 },
    data: { label: "Garage: Dealer vs Service" },
  },
  {
    id: "createSeparateCard",
    position: { x: 700, y: 3140 },
    data: { label: "Create Separate UMB Card" },
  },

  // Garage Type
  {
    id: "checkGarageType",
    position: { x: 550, y: 3220 },
    data: { label: "Dealer or Service?" },
    style: { background: "#FFE4B5" },
  },
  {
    id: "setGarageDealer",
    position: { x: 450, y: 3300 },
    data: { label: "LOB: GARAGE\nAssign: Charity Diezman LA" },
  },
  {
    id: "setGarageService",
    position: { x: 650, y: 3300 },
    data: { label: "LOB: PACKAGE\nDesc: Garage Service" },
  },

  // UMB Cards
  {
    id: "setupPrimaryCard",
    position: { x: 700, y: 3220 },
    data: { label: "Setup Primary Card" },
  },
  {
    id: "setupUMBCard",
    position: { x: 700, y: 3300 },
    data: { label: "Setup UMB Card Wholesale" },
  },
  {
    id: "linkCards",
    position: { x: 700, y: 3380 },
    data: { label: "Link Cards with File Marks & Notes" },
  },

  // State & Company
  {
    id: "selectState",
    position: { x: 400, y: 3460 },
    data: { label: "Select State Domiciled" },
  },
  {
    id: "setCompany",
    position: { x: 400, y: 3540 },
    data: { label: "Set Company: CLEARANCE CARRIER" },
  },
  {
    id: "setIssuingOffice",
    position: { x: 400, y: 3620 },
    data: { label: "Set Issuing Office by State" },
  },

  // Special Programs
  {
    id: "verifyUW",
    position: { x: 400, y: 3700 },
    data: { label: "Verify UW Assignment" },
  },
  {
    id: "checkSpecialProgram",
    position: { x: 400, y: 3780 },
    data: { label: "Special Program?" },
    style: { background: "#FFE4B5" },
  },
  {
    id: "assignCharity",
    position: { x: 100, y: 3860 },
    data: { label: "Assign: Charity Diezman (Garage LA)" },
  },
  {
    id: "assignJohn",
    position: { x: 250, y: 3860 },
    data: { label: "Assign: John Hellyer (Towing)" },
  },
  {
    id: "assignForestryLead",
    position: { x: 400, y: 3860 },
    data: { label: "Assign: Forestry Lead" },
  },
  {
    id: "assignWendy",
    position: { x: 550, y: 3860 },
    data: { label: "Assign: Wendy Vines (Wholesale)" },
  },
  {
    id: "useProducerList",
    position: { x: 700, y: 3860 },
    data: { label: "Use Producer List Assignment" },
  },

  // Policy Type & Effective Date
  {
    id: "setPolicyType",
    position: { x: 400, y: 3960 },
    data: { label: "Set Policy Type: New" },
  },
  {
    id: "setEffectiveDate",
    position: { x: 400, y: 4040 },
    data: { label: "Set Effective Date" },
  },
  {
    id: "checkEffDateRules",
    position: { x: 400, y: 4120 },
    data: { label: "Effective Date Check" },
    style: { background: "#FFE4B5" },
  },
  {
    id: "set7DaysOut",
    position: { x: 250, y: 4200 },
    data: { label: "Set 7 Days from Current (Past/Current Date)" },
  },
  {
    id: "keepEffDate",
    position: { x: 400, y: 4200 },
    data: { label: "Keep Application Date (Future Valid)" },
  },
  {
    id: "fileNoteDiscrepancy",
    position: { x: 550, y: 4200 },
    data: { label: "File Note: Date Discrepancy" },
  },

  // Business Description
  {
    id: "enterDescription",
    position: { x: 400, y: 4300 },
    data: { label: "Enter Business Description" },
  },
  {
    id: "findDescription",
    position: { x: 400, y: 4380 },
    data: { label: "Description Source" },
    style: { background: "#FFE4B5" },
  },
  {
    id: "useNatureDesc",
    position: { x: 150, y: 4460 },
    data: { label: "Use Nature of Business (Page 2)" },
  },
  {
    id: "usePremisesDesc",
    position: { x: 300, y: 4460 },
    data: { label: "Use Premises Description" },
  },
  {
    id: "useEmailDesc",
    position: { x: 450, y: 4460 },
    data: { label: "Use Email Description" },
  },
  {
    id: "useNarrativeDesc",
    position: { x: 600, y: 4460 },
    data: { label: "Use Narrative" },
  },

  // Format Description
  {
    id: "formatDescription",
    position: { x: 400, y: 4560 },
    data: { label: "Format: Capitalize, Use &, Commas" },
  },
  {
    id: "specialDescFormat",
    position: { x: 400, y: 4640 },
    data: { label: "Special Format?" },
    style: { background: "#FFE4B5" },
  },
  {
    id: "truckingDesc",
    position: { x: 200, y: 4720 },
    data: { label: "Trucking - Hauls Description" },
  },
  {
    id: "garageDealerDesc",
    position: { x: 350, y: 4720 },
    data: { label: "GARAGE DEALER - Description" },
  },
  {
    id: "garageServiceDesc",
    position: { x: 500, y: 4720 },
    data: { label: "GARAGE SERVICE - Description" },
  },
  {
    id: "standardDesc",
    position: { x: 650, y: 4720 },
    data: { label: "Standard Description Format" },
  },

  // Prior Carrier
  {
    id: "enterPriorCarrier",
    position: { x: 400, y: 4820 },
    data: { label: "Enter Prior Carrier Info" },
  },
  {
    id: "findPriorCarrier",
    position: { x: 400, y: 4900 },
    data: { label: "Prior Carrier Found?" },
    style: { background: "#FFE4B5" },
  },
  {
    id: "selectFromDropdown",
    position: { x: 250, y: 4980 },
    data: { label: "Select from Dropdown (Found in IMS)" },
  },
  {
    id: "markUnknown",
    position: { x: 400, y: 4980 },
    data: { label: "Mark as Unknown\nFile Note: Carrier Not in IMS" },
  },
  {
    id: "markUnknownNoInfo",
    position: { x: 550, y: 4980 },
    data: { label: "Mark as Unknown (No Info)" },
  },

  // Review Policy
  {
    id: "reviewPolicyInfo",
    position: { x: 400, y: 5080 },
    data: { label: "Review Policy Information" },
  },
  {
    id: "verifyInsuredInfo",
    position: { x: 400, y: 5160 },
    data: { label: "Verify Insured Info:\n- Business Name\n- FEIN\n- DBA" },
  },
  {
    id: "verifyMailingAddress",
    position: { x: 400, y: 5260 },
    data: { label: "Verify Mailing Address & Phone" },
  },
  {
    id: "setBillingAddress",
    position: { x: 400, y: 5340 },
    data: { label: "Set Billing Address" },
  },
  {
    id: "checkSecondAddress",
    position: { x: 400, y: 5420 },
    data: { label: "Second Address Exists?" },
    style: { background: "#FFE4B5" },
  },
  {
    id: "useSecondAddress",
    position: { x: 250, y: 5500 },
    data: { label: "Use Second Address" },
  },
  {
    id: "copyMailingAddress",
    position: { x: 400, y: 5500 },
    data: { label: "Copy Mailing Address" },
  },
  {
    id: "leaveBlank",
    position: { x: 550, y: 5500 },
    data: { label: "Leave Billing Address Blank (PO Box)" },
  },

  // Save & Summary
  {
    id: "savePolicyInfo",
    position: { x: 400, y: 5600 },
    data: { label: "Click Save" },
  },
  {
    id: "viewInsuredSummary",
    position: { x: 400, y: 5680 },
    data: { label: "View Insured Summary" },
  },
  {
    id: "relateFiles",
    position: { x: 400, y: 5760 },
    data: { label: "Relate Files in ImageRight" },
  },
  {
    id: "getPreviousControl",
    position: { x: 400, y: 5840 },
    data: { label: "Get Previous Control # from Summary" },
  },
  {
    id: "addRelatedFiles",
    position: { x: 400, y: 5920 },
    data: { label: "Add Related Files in IR" },
  },
  {
    id: "printInsuredSummary",
    position: { x: 400, y: 6000 },
    data: { label: "Print Insured Summary to IR" },
  },
  {
    id: "importSummary",
    position: { x: 400, y: 6080 },
    data: {
      label:
        "Import as: INSURED SUMMARY REPORT\nTo: Prior to Binding/Quote App/Misc",
    },
  },

  // Autoprocessing
  {
    id: "startAutoProcess",
    position: { x: 400, y: 6180 },
    data: { label: "Start Autoprocessing" },
  },
  {
    id: "selectNewCard",
    position: { x: 400, y: 6260 },
    data: { label: "Select New Card in IR" },
  },
  {
    id: "enterControlNum",
    position: { x: 400, y: 6340 },
    data: { label: "Enter Control Number" },
  },
  {
    id: "verifyControlMatch",
    position: { x: 400, y: 6420 },
    data: { label: "Control # Matches?" },
    style: { background: "#FFE4B5" },
  },
  {
    id: "fixControlNum",
    position: { x: 250, y: 6500 },
    data: { label: "Fix Control Number" },
  },
  {
    id: "setDocumentType",
    position: { x: 400, y: 6580 },
    data: { label: "Set Document Type: Misc-Misc" },
  },
  {
    id: "setFolder",
    position: { x: 400, y: 6660 },
    data: { label: "Set Folder: Prior to Binding/Correspondence" },
  },

  // Priority & Send
  {
    id: "setTaskPriority",
    position: { x: 400, y: 6740 },
    data: { label: "Set Task Priority" },
    style: { background: "#FFE4B5" },
  },
  {
    id: "setPrio1",
    position: { x: 300, y: 6820 },
    data: { label: "Priority: 1 (Insty)" },
  },
  {
    id: "setPrio5",
    position: { x: 500, y: 6820 },
    data: { label: "Priority: 5 (Non-Insty)" },
  },
  {
    id: "sendToUW",
    position: { x: 400, y: 6920 },
    data: { label: "Send to User: Assigned UW" },
  },
  {
    id: "resumeUpdateRelease",
    position: { x: 400, y: 7000 },
    data: { label: "Resume > Update > Release" },
  },

  // Validation
  {
    id: "validationCheck",
    position: { x: 400, y: 7100 },
    data: { label: "Manual Validation Checklist" },
    style: { background: "#DDA0DD" },
  },
  {
    id: "validateIMS",
    position: { x: 400, y: 7180 },
    data: { label: "Validate IMS Data Against ACORD" },
  },
  {
    id: "checkPrimaryInfo",
    position: { x: 400, y: 7260 },
    data: {
      label:
        "Check Primary Info:\n- Entity Type\n- Name\n- FEIN\n- Address\n- Phone\n- Email\n- DBA",
    },
  },
  {
    id: "checkContactInfo",
    position: { x: 400, y: 7380 },
    data: {
      label:
        "Check Contact Info:\n- Contact Type\n- First/Last Name\n- Address\n- Phone\n- Email",
    },
  },
  {
    id: "checkSubmissionInfo",
    position: { x: 400, y: 7500 },
    data: {
      label:
        "Check Submission Info:\n- Producer Name\n- UW Name\n- Line of Business\n- State\n- Company\n- Issuing Office\n- Effective Date\n- Description\n- Prior Carrier",
    },
  },
  {
    id: "checkAddresses",
    position: { x: 400, y: 7660 },
    data: { label: "Check Mailing & Billing Addresses" },
  },
  {
    id: "changesNeeded",
    position: { x: 400, y: 7740 },
    data: { label: "Changes Needed?" },
    style: { background: "#FFE4B5" },
  },

  // Corrections
  {
    id: "makeCorrections",
    position: { x: 250, y: 7820 },
    data: { label: "Make Corrections in IMS" },
  },
  {
    id: "reprintSummary",
    position: { x: 250, y: 7900 },
    data: { label: "Reprint Insured Summary" },
  },
  {
    id: "deleteOldSummary",
    position: { x: 250, y: 7980 },
    data: { label: "Delete Previous Summary" },
  },
  {
    id: "importNewSummary",
    position: { x: 250, y: 8060 },
    data: { label: "Import New Summary: INSURED SUMMARY REPORT" },
  },

  // Final
  {
    id: "finalReview",
    position: { x: 400, y: 8160 },
    data: { label: "Final Review Complete" },
    style: { background: "#87CEEB" },
  },
  {
    id: "backToClearance",
    position: { x: 400, y: 8240 },
    data: { label: "Return to Clearance Box" },
  },
  {
    id: "processComplete",
    type: "output",
    position: { x: 400, y: 8320 },
    data: { label: "Submission Processed" },
    style: { background: "#87CEEB", border: "2px solid #333" },
  },
  {
    id: "moreSubmissions",
    position: { x: 400, y: 8420 },
    data: { label: "More Submissions?" },
    style: { background: "#FFE4B5" },
  },
  {
    id: "endDay",
    type: "output",
    position: { x: 600, y: 8500 },
    data: { label: "End of Processing" },
    style: { background: "#FFB6C1", border: "2px solid #333" },
  },
];

export const initialEdges = [
  // Start to IR
  { id: "e-start-openIR", source: "start", target: "openIR", animated: true },
  { id: "e-openIR-establishRDC", source: "openIR", target: "establishRDC" },
  {
    id: "e-establishRDC-connectRDC",
    source: "establishRDC",
    target: "connectRDC",
    label: "No",
  },
  {
    id: "e-connectRDC-fetchClearance",
    source: "connectRDC",
    target: "fetchClearance",
  },
  {
    id: "e-establishRDC-fetchClearance",
    source: "establishRDC",
    target: "fetchClearance",
    label: "Yes",
  },

  // Priority
  {
    id: "e-fetchClearance-checkEffDate",
    source: "fetchClearance",
    target: "checkEffDate",
  },
  {
    id: "e-checkEffDate-prioritizeFiles",
    source: "checkEffDate",
    target: "prioritizeFiles",
  },
  {
    id: "e-prioritizeFiles-setPriority1",
    source: "prioritizeFiles",
    target: "setPriority1",
    label: "Insty ≤14 days",
  },
  {
    id: "e-prioritizeFiles-setPriority5",
    source: "prioritizeFiles",
    target: "setPriority5",
    label: "Regular",
  },
  {
    id: "e-setPriority1-sortByDate",
    source: "setPriority1",
    target: "sortByDate",
  },
  {
    id: "e-setPriority5-sortByDate",
    source: "setPriority5",
    target: "sortByDate",
  },

  // Open & Process
  {
    id: "e-sortByDate-openSubmission",
    source: "sortByDate",
    target: "openSubmission",
  },
  {
    id: "e-openSubmission-checkEffDateApp",
    source: "openSubmission",
    target: "checkEffDateApp",
  },
  {
    id: "e-checkEffDateApp-markEffDate",
    source: "checkEffDateApp",
    target: "markEffDate",
  },
  {
    id: "e-markEffDate-autoProcessCheck",
    source: "markEffDate",
    target: "autoProcessCheck",
  },
  {
    id: "e-autoProcessCheck-autoProcess",
    source: "autoProcessCheck",
    target: "autoProcess",
    label: "Yes",
  },
  {
    id: "e-autoProcessCheck-manualOpen",
    source: "autoProcessCheck",
    target: "manualOpen",
    label: "No",
  },
  {
    id: "e-autoProcess-orderPages",
    source: "autoProcess",
    target: "orderPages",
  },
  { id: "e-manualOpen-orderPages", source: "manualOpen", target: "orderPages" },
  { id: "e-orderPages-labelPages", source: "orderPages", target: "labelPages" },
  {
    id: "e-labelPages-moveCorrespondence",
    source: "labelPages",
    target: "moveCorrespondence",
  },
  {
    id: "e-moveCorrespondence-checkDNQ",
    source: "moveCorrespondence",
    target: "checkDNQ",
  },

  // DNQ Check
  { id: "e-checkDNQ-onDNQList", source: "checkDNQ", target: "onDNQList" },
  {
    id: "e-onDNQList-dnqProcess",
    source: "onDNQList",
    target: "dnqProcess",
    label: "Yes",
  },
  { id: "e-dnqProcess-endDNQ", source: "dnqProcess", target: "endDNQ" },
  {
    id: "e-onDNQList-searchIMS",
    source: "onDNQList",
    target: "searchIMS",
    label: "No",
  },

  // IMS Search
  {
    id: "e-searchIMS-crossReference",
    source: "searchIMS",
    target: "crossReference",
  },
  {
    id: "e-crossReference-foundInIMS",
    source: "crossReference",
    target: "foundInIMS",
  },
  {
    id: "e-foundInIMS-createInsured",
    source: "foundInIMS",
    target: "createInsured",
    label: "No - New Insured",
  },
  {
    id: "e-foundInIMS-checkSubmissionType",
    source: "foundInIMS",
    target: "checkSubmissionType",
    label: "Yes - Match Found",
  },

  // New Insured
  {
    id: "e-createInsured-enterInsuredInfo",
    source: "createInsured",
    target: "enterInsuredInfo",
  },
  {
    id: "e-enterInsuredInfo-enterContactInfo",
    source: "enterInsuredInfo",
    target: "enterContactInfo",
  },
  {
    id: "e-enterContactInfo-createSubmission",
    source: "enterContactInfo",
    target: "createSubmission",
  },

  // Submission Type
  {
    id: "e-checkSubmissionType-createSubmission",
    source: "checkSubmissionType",
    target: "createSubmission",
    label: "New Submission",
  },
  {
    id: "e-checkSubmissionType-checkControlNum",
    source: "checkSubmissionType",
    target: "checkControlNum",
    label: "Renewal",
  },
  {
    id: "e-checkControlNum-rescheduleRenewal",
    source: "checkControlNum",
    target: "rescheduleRenewal",
    label: "No",
  },
  {
    id: "e-checkControlNum-createSubmission",
    source: "checkControlNum",
    target: "createSubmission",
    label: "Yes",
  },
  {
    id: "e-rescheduleRenewal-deletePhotos",
    source: "rescheduleRenewal",
    target: "deletePhotos",
  },

  // Producer
  {
    id: "e-createSubmission-enterProducer",
    source: "createSubmission",
    target: "enterProducer",
  },
  {
    id: "e-enterProducer-producerFound",
    source: "enterProducer",
    target: "producerFound",
  },
  {
    id: "e-producerFound-addProducer",
    source: "producerFound",
    target: "addProducer",
    label: "No",
  },
  {
    id: "e-producerFound-selectProducer",
    source: "producerFound",
    target: "selectProducer",
    label: "Yes",
  },
  {
    id: "e-addProducer-checkAgency",
    source: "addProducer",
    target: "checkAgency",
  },
  {
    id: "e-checkAgency-contactMarketing",
    source: "checkAgency",
    target: "contactMarketing",
    label: "No",
  },
  {
    id: "e-checkAgency-addToAgency",
    source: "checkAgency",
    target: "addToAgency",
    label: "Yes",
  },
  {
    id: "e-contactMarketing-waitForSetup",
    source: "contactMarketing",
    target: "waitForSetup",
  },
  {
    id: "e-waitForSetup-selectProducer",
    source: "waitForSetup",
    target: "selectProducer",
  },
  {
    id: "e-addToAgency-selectProducer",
    source: "addToAgency",
    target: "selectProducer",
  },

  // UW & Quote
  {
    id: "e-selectProducer-assignUW",
    source: "selectProducer",
    target: "assignUW",
  },
  {
    id: "e-assignUW-selectQuoteType",
    source: "assignUW",
    target: "selectQuoteType",
  },
  {
    id: "e-selectQuoteType-enterQuoteInfo",
    source: "selectQuoteType",
    target: "enterQuoteInfo",
  },
  {
    id: "e-enterQuoteInfo-setQuotingOffice",
    source: "enterQuoteInfo",
    target: "setQuotingOffice",
  },
  {
    id: "e-setQuotingOffice-selectLOB",
    source: "setQuotingOffice",
    target: "selectLOB",
  },

  // LOB Selection
  {
    id: "e-selectLOB-setMGALOB",
    source: "selectLOB",
    target: "setMGALOB",
    label: "MGA Program",
  },
  {
    id: "e-selectLOB-setWholesaleLOB",
    source: "selectLOB",
    target: "setWholesaleLOB",
    label: "Wholesale",
  },
  {
    id: "e-selectLOB-setTruckingLOB",
    source: "selectLOB",
    target: "setTruckingLOB",
    label: "Trucking",
  },
  {
    id: "e-selectLOB-setGarageLOB",
    source: "selectLOB",
    target: "setGarageLOB",
    label: "Garage",
  },
  {
    id: "e-selectLOB-createSeparateCard",
    source: "selectLOB",
    target: "createSeparateCard",
    label: "Umbrella/Excess",
  },

  { id: "e-setMGALOB-selectState", source: "setMGALOB", target: "selectState" },
  {
    id: "e-setWholesaleLOB-selectState",
    source: "setWholesaleLOB",
    target: "selectState",
  },
  {
    id: "e-setTruckingLOB-selectState",
    source: "setTruckingLOB",
    target: "selectState",
  },

  // Garage
  {
    id: "e-setGarageLOB-checkGarageType",
    source: "setGarageLOB",
    target: "checkGarageType",
  },
  {
    id: "e-checkGarageType-setGarageDealer",
    source: "checkGarageType",
    target: "setGarageDealer",
    label: "Dealer",
  },
  {
    id: "e-checkGarageType-setGarageService",
    source: "checkGarageType",
    target: "setGarageService",
    label: "Service",
  },
  {
    id: "e-setGarageDealer-selectState",
    source: "setGarageDealer",
    target: "selectState",
  },
  {
    id: "e-setGarageService-selectState",
    source: "setGarageService",
    target: "selectState",
  },

  // UMB
  {
    id: "e-createSeparateCard-setupPrimaryCard",
    source: "createSeparateCard",
    target: "setupPrimaryCard",
  },
  {
    id: "e-setupPrimaryCard-setupUMBCard",
    source: "setupPrimaryCard",
    target: "setupUMBCard",
  },
  {
    id: "e-setupUMBCard-linkCards",
    source: "setupUMBCard",
    target: "linkCards",
  },
  { id: "e-linkCards-selectState", source: "linkCards", target: "selectState" },

  // State & Company
  {
    id: "e-selectState-setCompany",
    source: "selectState",
    target: "setCompany",
  },
  {
    id: "e-setCompany-setIssuingOffice",
    source: "setCompany",
    target: "setIssuingOffice",
  },
  {
    id: "e-setIssuingOffice-verifyUW",
    source: "setIssuingOffice",
    target: "verifyUW",
  },
  {
    id: "e-verifyUW-checkSpecialProgram",
    source: "verifyUW",
    target: "checkSpecialProgram",
  },

  // Special Programs
  {
    id: "e-checkSpecialProgram-assignCharity",
    source: "checkSpecialProgram",
    target: "assignCharity",
    label: "Garage LA",
  },
  {
    id: "e-checkSpecialProgram-assignJohn",
    source: "checkSpecialProgram",
    target: "assignJohn",
    label: "Towing",
  },
  {
    id: "e-checkSpecialProgram-assignForestryLead",
    source: "checkSpecialProgram",
    target: "assignForestryLead",
    label: "Forestry",
  },
  {
    id: "e-checkSpecialProgram-assignWendy",
    source: "checkSpecialProgram",
    target: "assignWendy",
    label: "Wholesale",
  },
  {
    id: "e-checkSpecialProgram-useProducerList",
    source: "checkSpecialProgram",
    target: "useProducerList",
    label: "Standard",
  },

  {
    id: "e-assignCharity-setPolicyType",
    source: "assignCharity",
    target: "setPolicyType",
  },
  {
    id: "e-assignJohn-setPolicyType",
    source: "assignJohn",
    target: "setPolicyType",
  },
  {
    id: "e-assignForestryLead-setPolicyType",
    source: "assignForestryLead",
    target: "setPolicyType",
  },
  {
    id: "e-assignWendy-setPolicyType",
    source: "assignWendy",
    target: "setPolicyType",
  },
  {
    id: "e-useProducerList-setPolicyType",
    source: "useProducerList",
    target: "setPolicyType",
  },

  // Effective Date
  {
    id: "e-setPolicyType-setEffectiveDate",
    source: "setPolicyType",
    target: "setEffectiveDate",
  },
  {
    id: "e-setEffectiveDate-checkEffDateRules",
    source: "setEffectiveDate",
    target: "checkEffDateRules",
  },
  {
    id: "e-checkEffDateRules-set7DaysOut",
    source: "checkEffDateRules",
    target: "set7DaysOut",
    label: "Past/Current",
  },
  {
    id: "e-checkEffDateRules-keepEffDate",
    source: "checkEffDateRules",
    target: "keepEffDate",
    label: "Future Valid",
  },
  {
    id: "e-checkEffDateRules-fileNoteDiscrepancy",
    source: "checkEffDateRules",
    target: "fileNoteDiscrepancy",
    label: "Discrepancy",
  },

  {
    id: "e-set7DaysOut-enterDescription",
    source: "set7DaysOut",
    target: "enterDescription",
  },
  {
    id: "e-keepEffDate-enterDescription",
    source: "keepEffDate",
    target: "enterDescription",
  },
  {
    id: "e-fileNoteDiscrepancy-enterDescription",
    source: "fileNoteDiscrepancy",
    target: "enterDescription",
  },

  // Description
  {
    id: "e-enterDescription-findDescription",
    source: "enterDescription",
    target: "findDescription",
  },
  {
    id: "e-findDescription-useNatureDesc",
    source: "findDescription",
    target: "useNatureDesc",
    label: "Page 2",
  },
  {
    id: "e-findDescription-usePremisesDesc",
    source: "findDescription",
    target: "usePremisesDesc",
    label: "Premises",
  },
  {
    id: "e-findDescription-useEmailDesc",
    source: "findDescription",
    target: "useEmailDesc",
    label: "Email",
  },
  {
    id: "e-findDescription-useNarrativeDesc",
    source: "findDescription",
    target: "useNarrativeDesc",
    label: "Narrative",
  },

  {
    id: "e-useNatureDesc-formatDescription",
    source: "useNatureDesc",
    target: "formatDescription",
  },
  {
    id: "e-usePremisesDesc-formatDescription",
    source: "usePremisesDesc",
    target: "formatDescription",
  },
  {
    id: "e-useEmailDesc-formatDescription",
    source: "useEmailDesc",
    target: "formatDescription",
  },
  {
    id: "e-useNarrativeDesc-formatDescription",
    source: "useNarrativeDesc",
    target: "formatDescription",
  },

  {
    id: "e-formatDescription-specialDescFormat",
    source: "formatDescription",
    target: "specialDescFormat",
  },
  {
    id: "e-specialDescFormat-truckingDesc",
    source: "specialDescFormat",
    target: "truckingDesc",
    label: "Trucking",
  },
  {
    id: "e-specialDescFormat-garageDealerDesc",
    source: "specialDescFormat",
    target: "garageDealerDesc",
    label: "Garage Dealer",
  },
  {
    id: "e-specialDescFormat-garageServiceDesc",
    source: "specialDescFormat",
    target: "garageServiceDesc",
    label: "Garage Service",
  },
  {
    id: "e-specialDescFormat-standardDesc",
    source: "specialDescFormat",
    target: "standardDesc",
    label: "Standard",
  },

  {
    id: "e-truckingDesc-enterPriorCarrier",
    source: "truckingDesc",
    target: "enterPriorCarrier",
  },
  {
    id: "e-garageDealerDesc-enterPriorCarrier",
    source: "garageDealerDesc",
    target: "enterPriorCarrier",
  },
  {
    id: "e-garageServiceDesc-enterPriorCarrier",
    source: "garageServiceDesc",
    target: "enterPriorCarrier",
  },
  {
    id: "e-standardDesc-enterPriorCarrier",
    source: "standardDesc",
    target: "enterPriorCarrier",
  },

  // Prior Carrier
  {
    id: "e-enterPriorCarrier-findPriorCarrier",
    source: "enterPriorCarrier",
    target: "findPriorCarrier",
  },
  {
    id: "e-findPriorCarrier-selectFromDropdown",
    source: "findPriorCarrier",
    target: "selectFromDropdown",
    label: "Found",
  },
  {
    id: "e-findPriorCarrier-markUnknown",
    source: "findPriorCarrier",
    target: "markUnknown",
    label: "Not Found",
  },
  {
    id: "e-findPriorCarrier-markUnknownNoInfo",
    source: "findPriorCarrier",
    target: "markUnknownNoInfo",
    label: "No Info",
  },

  {
    id: "e-selectFromDropdown-reviewPolicyInfo",
    source: "selectFromDropdown",
    target: "reviewPolicyInfo",
  },
  {
    id: "e-markUnknown-reviewPolicyInfo",
    source: "markUnknown",
    target: "reviewPolicyInfo",
  },
  {
    id: "e-markUnknownNoInfo-reviewPolicyInfo",
    source: "markUnknownNoInfo",
    target: "reviewPolicyInfo",
  },

  // Review & Save
  {
    id: "e-reviewPolicyInfo-verifyInsuredInfo",
    source: "reviewPolicyInfo",
    target: "verifyInsuredInfo",
  },
  {
    id: "e-verifyInsuredInfo-verifyMailingAddress",
    source: "verifyInsuredInfo",
    target: "verifyMailingAddress",
  },
  {
    id: "e-verifyMailingAddress-setBillingAddress",
    source: "verifyMailingAddress",
    target: "setBillingAddress",
  },
  {
    id: "e-setBillingAddress-checkSecondAddress",
    source: "setBillingAddress",
    target: "checkSecondAddress",
  },

  {
    id: "e-checkSecondAddress-useSecondAddress",
    source: "checkSecondAddress",
    target: "useSecondAddress",
    label: "Yes",
  },
  {
    id: "e-checkSecondAddress-copyMailingAddress",
    source: "checkSecondAddress",
    target: "copyMailingAddress",
    label: "No",
  },
  {
    id: "e-checkSecondAddress-leaveBlank",
    source: "checkSecondAddress",
    target: "leaveBlank",
    label: "PO Box",
  },

  {
    id: "e-useSecondAddress-savePolicyInfo",
    source: "useSecondAddress",
    target: "savePolicyInfo",
  },
  {
    id: "e-copyMailingAddress-savePolicyInfo",
    source: "copyMailingAddress",
    target: "savePolicyInfo",
  },
  {
    id: "e-leaveBlank-savePolicyInfo",
    source: "leaveBlank",
    target: "savePolicyInfo",
  },

  // Summary
  {
    id: "e-savePolicyInfo-viewInsuredSummary",
    source: "savePolicyInfo",
    target: "viewInsuredSummary",
  },
  {
    id: "e-viewInsuredSummary-relateFiles",
    source: "viewInsuredSummary",
    target: "relateFiles",
  },
  {
    id: "e-relateFiles-getPreviousControl",
    source: "relateFiles",
    target: "getPreviousControl",
  },
  {
    id: "e-getPreviousControl-addRelatedFiles",
    source: "getPreviousControl",
    target: "addRelatedFiles",
  },
  {
    id: "e-addRelatedFiles-printInsuredSummary",
    source: "addRelatedFiles",
    target: "printInsuredSummary",
  },
  {
    id: "e-printInsuredSummary-importSummary",
    source: "printInsuredSummary",
    target: "importSummary",
  },

  // Autoprocessing
  {
    id: "e-importSummary-startAutoProcess",
    source: "importSummary",
    target: "startAutoProcess",
  },
  {
    id: "e-startAutoProcess-selectNewCard",
    source: "startAutoProcess",
    target: "selectNewCard",
  },
  {
    id: "e-selectNewCard-enterControlNum",
    source: "selectNewCard",
    target: "enterControlNum",
  },
  {
    id: "e-enterControlNum-verifyControlMatch",
    source: "enterControlNum",
    target: "verifyControlMatch",
  },
  {
    id: "e-verifyControlMatch-fixControlNum",
    source: "verifyControlMatch",
    target: "fixControlNum",
    label: "No",
  },
  {
    id: "e-verifyControlMatch-setDocumentType",
    source: "verifyControlMatch",
    target: "setDocumentType",
    label: "Yes",
  },
  {
    id: "e-fixControlNum-setDocumentType",
    source: "fixControlNum",
    target: "setDocumentType",
  },
  {
    id: "e-setDocumentType-setFolder",
    source: "setDocumentType",
    target: "setFolder",
  },
  {
    id: "e-setFolder-setTaskPriority",
    source: "setFolder",
    target: "setTaskPriority",
  },

  {
    id: "e-setTaskPriority-setPrio1",
    source: "setTaskPriority",
    target: "setPrio1",
    label: "Insty",
  },
  {
    id: "e-setTaskPriority-setPrio5",
    source: "setTaskPriority",
    target: "setPrio5",
    label: "Non-Insty",
  },
  { id: "e-setPrio1-sendToUW", source: "setPrio1", target: "sendToUW" },
  { id: "e-setPrio5-sendToUW", source: "setPrio5", target: "sendToUW" },

  {
    id: "e-sendToUW-resumeUpdateRelease",
    source: "sendToUW",
    target: "resumeUpdateRelease",
  },

  // Validation
  {
    id: "e-resumeUpdateRelease-validationCheck",
    source: "resumeUpdateRelease",
    target: "validationCheck",
  },
  {
    id: "e-validationCheck-validateIMS",
    source: "validationCheck",
    target: "validateIMS",
  },
  {
    id: "e-validateIMS-checkPrimaryInfo",
    source: "validateIMS",
    target: "checkPrimaryInfo",
  },
  {
    id: "e-checkPrimaryInfo-checkContactInfo",
    source: "checkPrimaryInfo",
    target: "checkContactInfo",
  },
  {
    id: "e-checkContactInfo-checkSubmissionInfo",
    source: "checkContactInfo",
    target: "checkSubmissionInfo",
  },
  {
    id: "e-checkSubmissionInfo-checkAddresses",
    source: "checkSubmissionInfo",
    target: "checkAddresses",
  },
  {
    id: "e-checkAddresses-changesNeeded",
    source: "checkAddresses",
    target: "changesNeeded",
  },

  {
    id: "e-changesNeeded-makeCorrections",
    source: "changesNeeded",
    target: "makeCorrections",
    label: "Yes",
  },
  {
    id: "e-changesNeeded-finalReview",
    source: "changesNeeded",
    target: "finalReview",
    label: "No",
  },

  {
    id: "e-makeCorrections-reprintSummary",
    source: "makeCorrections",
    target: "reprintSummary",
  },
  {
    id: "e-reprintSummary-deleteOldSummary",
    source: "reprintSummary",
    target: "deleteOldSummary",
  },
  {
    id: "e-deleteOldSummary-importNewSummary",
    source: "deleteOldSummary",
    target: "importNewSummary",
  },
  {
    id: "e-importNewSummary-finalReview",
    source: "importNewSummary",
    target: "finalReview",
  },

  // Final
  {
    id: "e-finalReview-backToClearance",
    source: "finalReview",
    target: "backToClearance",
  },
  {
    id: "e-backToClearance-processComplete",
    source: "backToClearance",
    target: "processComplete",
  },
  {
    id: "e-processComplete-moreSubmissions",
    source: "processComplete",
    target: "moreSubmissions",
  },
  {
    id: "e-moreSubmissions-fetchClearance",
    source: "moreSubmissions",
    target: "fetchClearance",
    label: "Yes",
  },
  {
    id: "e-moreSubmissions-endDay",
    source: "moreSubmissions",
    target: "endDay",
    label: "No",
  },
];
