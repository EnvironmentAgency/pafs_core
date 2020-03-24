# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true

module PafsCore
  module SpreadsheetCustomStyles
    SECOND_ROW = {
      A: { bg_color: "99FF39BB", title: "PROJECT DETAILS" },
      AK: { bg_color: "AACC66FF", title: "PROJECT MILESTONES" },
      AO: { bg_color: "AA88FF4D", title: "FUNDING" },
      GC: { bg_color: "AA66D9FF", title: "OUTCOMES" },
      KY: { bg_color: "AACC33CC", title: "Environmental Benefits" },
      LH: { bg_color: "AA404040", title: "SUMMARY" },
      LP: { bg_color: "AAE6E6E6", title: "PPMT" }
    }.freeze

    FOURTH_ROW = {
      A: {
        bg_color: "FF80FF00",
        title: "REFERENCE"
      },
      F: {
        bg_color: "99FF39BB",
        title: "ORGANISATION"
      },
      K: {
        bg_color: "FFCC99FF",
        title: "FLAGS"
      },
      O: {
        bg_color: "FFFFCCE6",
        title: "LOCATION"
      },
      T: {
        bg_color: "FF00FFFF",
        title: "DESCRIPTIVE DETAILS"
      },
      AB: {
        bg_color: "FFFF6600",
        title: "PARTNERSHIP FUNDING SUMMARY\n(Values to be taken from PF Calculator)"
      },
      AI: {
        bg_color: "FF0066FF",
        title: "ADDITIONAL DETAILS"
      },
      AK: {
        bg_color: "FFFFCC00",
        title: "GATEWAY DATES"
      },
      AO: {
        bg_color: "FFBFBFBF",
        title: "PROJECT TOTALS\n(calculated from relevant columns)\n £ CASH"
      },
      BG: {
        bg_color: "FF33D6FF",
        title: "TOTAL PROJECT EXPENDITURE\n(calculated from FCRM GiA to be expended +\
        Total Local Contributions Secured + Funding From Other EA Functions + Further Contributions\
        Required)\n£ CASH"
      },
      BU: {
        bg_color: "FFFF9DB3",
        title: "FCRM GiA TO BE EXPENDED ON PROJECT\n£ CASH"
      },
      CI: {
        bg_color: "FFE60000",
        title: "GROWTH FUND\n£ CASH"
      },
      CW: {
        bg_color: "FFFFFFB3",
        title: "LOCAL LEVY SECURED\n £ CASH"
      },
      DK: {
        bg_color: "FFFFFFCC",
        title: "INTERNAL DRAINAGE BOARD PRECEPTS SECURED\n£ CASH"
      },
      DY: {
        bg_color: "FF99FF99",
        title: "PUBLICLY FUNDED CONTRIBUTIONS SECURED\n(Contract In Place,
        or In Negotiation)\n£ CASH"
      },
      EM: {
        bg_color: "FFB3FFFF",
        title: "PRIVATELY FUNDED CONTRIBUTIONS SECURED\n(Contract In Place,
        or In Negotiation)\n£ CASH"
      },
      FA: {
        bg_color: "FFB366FF",
        title: "FUNDING CONTRIBUTIONS FROM OTHER ENVIRONMENT AGENCY\
        FUNCTIONS/SOURCES\n(including WFD itemised in seperate columns to the right)\n£ CASH"
      },
      FO: {
        bg_color: "FFFF66C4",
        title: "FURTHER CONTRIBUTIONS REQUIRED\n£ CASH"
      },
      GC: {
        bg_color: "FF80D4FF",
        title: "Outcome Measures\nOM2 Delivery"
      },
      GQ: {
        bg_color: "FF80D4FF",
        title: "Outcome Measures\nOM2b Delivery"
      },
      HE: {
        bg_color: "FF80D4FF",
        title: "Outcome Measures\nOM2c Delivery"
      },
      HS: {
        bg_color: "FF33FFFF",
        title: "Outcome Measures\nOM3 Delivery"
      },
      IG: {
        bg_color: "FF33FFFF",
        title: "Outcome Measures\nOM3b Delivery"
      },
      IU: {
        bg_color: "FF33FFFF",
        title: "Outcome Measures\nOM3c Delivery"
      },
      JI: {
        bg_color: "FF73E600",
        title: "Outcome Measures\nOM4a Delivery"
      },
      JW: {
        bg_color: "FF73E600",
        title: "Outcome Measures\nOM4b Delivery"
      },
      KK: {
        bg_color: "FF73E600",
        title: "Outcome Measures\nOM4c Delivery"
      },
      KY: {
        bg_color: "AACC33CC",
        title: "Environmental performance specification indicators"
      },
      LH: {
        bg_color: "AA404040",
        title: "SCHEME OVERVIEW\n(calculated from relevant columns)"
      },
      LP: {
        bg_color: "AAE6E6E6",
        title: "FIELDS REQUIRED TO POPULATE PPMT"
      }
    }.freeze
  end
end
