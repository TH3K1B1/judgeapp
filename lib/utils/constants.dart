// This file should only contain run type and run labels
// Remove any contestant-related logic from here

enum RunType { qual1, qual2, final1, final2 }

const Map<RunType, String> runLabels = {
  RunType.qual1: 'Qual 1',
  RunType.qual2: 'Qual 2',
  RunType.final1: 'Final 1',
  RunType.final2: 'Final 2',
};
