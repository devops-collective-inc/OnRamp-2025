function Get-OnRampBuddyPair {
<#
.SYNOPSIS
    Pairs attendees with buddies from two separate groups.

.DESCRIPTION
    Randomly pairs each attendee with a unique buddy from a separate list.
    If there are more attendees than buddies, unmatched attendees are still
    included with a null buddy value. Buddies are never assigned more than
    once. The pairing is randomized on each function call.

.PARAMETER Attendee
    A list of attendees to be paired. Each attendee will be matched with one
    buddy, if enough buddies are available.

.PARAMETER Buddy
    A list of buddies to be paired. Each buddy is matched with one attendee
    at most.

.EXAMPLE
    Get-OnRampBuddyPair -Attendee Alex, Jordan -Buddy Casey, Morgan

.OUTPUTS
    PSCustomObject

.NOTES
    Author:  Mike F. Robbins
    Website: https://mikefrobbins.com/
    Twitter: @mikefrobbins
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string[]]$Attendee,

        [Parameter(Mandatory)]
        [string[]]$Buddy
    )

    # Shuffle both lists independently
    $shuffledAttendee = $Attendee | Sort-Object {Get-Random}
    $shuffledBuddy = $Buddy | Sort-Object {Get-Random}

    # Pair attendees to buddies (only while we have buddies left)
    for ($i = 0; $i -lt $shuffledAttendee.Count; $i++) {
        if ($i -lt $shuffledBuddy.Count) {
            [PSCustomObject]@{
                Attendee = $shuffledAttendee[$i]
                Buddy    = $shuffledBuddy[$i]
            }
        }
        else {
            # No buddy available — still return attendee with $null buddy
            [PSCustomObject]@{
                Attendee = $shuffledAttendee[$i]
                Buddy    = $null
            }
        }
    }

}
