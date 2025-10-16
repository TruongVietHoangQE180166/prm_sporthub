class Team {
  final String id;
  final String ownerId;
  final String ownerName;
  final String nameMatch;
  final String? descriptionMatch;
  final String nameSport;
  final DateTime timeMatch;
  final int maxPlayers;
  final String location;
  final String level;
  final String? numberPhone;
  final String? linkFacebook;
  final List<Member> members;
  final List<TeamJoinRequest> teamJoinRequest;

  Team({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.nameMatch,
    this.descriptionMatch,
    required this.nameSport,
    required this.timeMatch,
    required this.maxPlayers,
    required this.location,
    required this.level,
    this.numberPhone,
    this.linkFacebook,
    required this.members,
    required this.teamJoinRequest,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    var membersList = <Member>[];
    if (json['members'] != null) {
      membersList = (json['members'] as List)
          .map((member) => Member.fromJson(member))
          .toList();
    }

    var teamJoinRequestList = <TeamJoinRequest>[];
    if (json['teamJoinRequest'] != null) {
      teamJoinRequestList = (json['teamJoinRequest'] as List)
          .map((request) => TeamJoinRequest.fromJson(request))
          .toList();
    }

    return Team(
      id: json['id'],
      ownerId: json['ownerId'],
      ownerName: json['ownerName'],
      nameMatch: json['nameMatch'],
      descriptionMatch: json['descriptionMatch'],
      nameSport: json['nameSport'],
      timeMatch: DateTime.parse(json['timeMatch']),
      maxPlayers: json['maxPlayers'],
      location: json['location'],
      level: json['level'],
      numberPhone: json['numberPhone'],
      linkFacebook: json['linkFacebook'],
      members: membersList,
      teamJoinRequest: teamJoinRequestList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'nameMatch': nameMatch,
      'descriptionMatch': descriptionMatch,
      'nameSport': nameSport,
      'timeMatch': timeMatch.toIso8601String(),
      'maxPlayers': maxPlayers,
      'location': location,
      'level': level,
      'numberPhone': numberPhone,
      'linkFacebook': linkFacebook,
      'members': members.map((member) => member.toJson()).toList(),
      'teamJoinRequest':
          teamJoinRequest.map((request) => request.toJson()).toList(),
    };
  }
}

class Member {
  final String userId;
  final String username;
  final String? email;

  Member({
    required this.userId,
    required this.username,
    this.email,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      userId: json['userId'],
      username: json['username'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
    };
  }
}

class TeamJoinRequest {
  final String id;
  final String teamId;
  final String nameMatch;
  final String nameSport;
  final String userId;
  final String username;
  final String status;

  TeamJoinRequest({
    required this.id,
    required this.teamId,
    required this.nameMatch,
    required this.nameSport,
    required this.userId,
    required this.username,
    required this.status,
  });

  factory TeamJoinRequest.fromJson(Map<String, dynamic> json) {
    return TeamJoinRequest(
      id: json['id'],
      teamId: json['teamId'],
      nameMatch: json['nameMatch'],
      nameSport: json['nameSport'],
      userId: json['userId'],
      username: json['username'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teamId': teamId,
      'nameMatch': nameMatch,
      'nameSport': nameSport,
      'userId': userId,
      'username': username,
      'status': status,
    };
  }
}