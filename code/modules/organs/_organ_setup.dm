//These control the damage thresholds for the various ways of removing limbs
#define DROPLIMB_THRESHOLD_EDGE 5
#define DROPLIMB_THRESHOLD_TEAROFF 2
#define DROPLIMB_THRESHOLD_DESTROY 1

#define ORGAN_RECOVERY_THRESHOLD (5 MINUTES)

// With great numbers comes great priority
// Changes capacity by certain value
#define ORGAN_CAPACITY_EFFECT_OFFSET 1
// Multiplies capacity by this value
#define ORGAN_CAPACITY_EFFECT_MULT 2
// Limits capacity by this value
#define ORGAN_CAPACITY_EFFECT_LIMIT 3
// Keeps capacity at least at this value
#define ORGAN_CAPACITY_EFFECT_KEEP 4
