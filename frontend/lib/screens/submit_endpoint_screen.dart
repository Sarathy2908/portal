import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/team.dart';
import '../providers/team_provider.dart';
import '../providers/auth_provider.dart';
import 'queue_status_screen.dart';

class SubmitEndpointScreen extends StatefulWidget {
  const SubmitEndpointScreen({Key? key}) : super(key: key);

  @override
  State<SubmitEndpointScreen> createState() => _SubmitEndpointScreenState();
}

class _SubmitEndpointScreenState extends State<SubmitEndpointScreen> {
  final _formKey = GlobalKey<FormState>();
  final _teamIdController = TextEditingController();
  final _teamNameController = TextEditingController();
  final _endpointUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLastTeamData();
  }

  Future<void> _loadLastTeamData() async {
    final teamProvider = Provider.of<TeamProvider>(context, listen: false);
    await teamProvider.loadLastTeamData();
    
    if (teamProvider.currentTeam != null) {
      _teamIdController.text = teamProvider.currentTeam!.teamId;
      _teamNameController.text = teamProvider.currentTeam!.teamName;
      _endpointUrlController.text = teamProvider.currentTeam!.endpointUrl;
    }
  }

  @override
  void dispose() {
    _teamIdController.dispose();
    _teamNameController.dispose();
    _endpointUrlController.dispose();
    super.dispose();
  }

  Future<void> _submitEndpoint() async {
    if (_formKey.currentState!.validate()) {
      final team = Team(
        teamId: _teamIdController.text.trim(),
        teamName: _teamNameController.text.trim(),
        endpointUrl: _endpointUrlController.text.trim(),
      );

      final teamProvider = Provider.of<TeamProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Test authentication first
      print('Current user: ${authProvider.user?.email}');
      print('Token exists: ${authProvider.token != null}');
      print('Token preview: ${authProvider.token?.substring(0, 50)}...');
      
      teamProvider.setAuthToken(authProvider.token);
      final success = await teamProvider.submitEndpoint(team);

      if (success && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QueueStatusScreen(teamId: team.teamId),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(teamProvider.errorMessage ?? 'Failed to submit endpoint'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('ML Hackathon - Submit Endpoint'),
        backgroundColor: Colors.blue,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Center(
              child: Text(
                authProvider.user?.email ?? '',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
              
              if (confirm == true && mounted) {
                await authProvider.signOut();
              }
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Submit Your ML Endpoint',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _teamIdController,
                        decoration: const InputDecoration(
                          labelText: 'Team ID',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.badge),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter team ID';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _teamNameController,
                        decoration: const InputDecoration(
                          labelText: 'Team Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.group),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter team name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _endpointUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Endpoint URL',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.link),
                          hintText: 'https://your-endpoint.com/predict',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter endpoint URL';
                          }
                          if (!value.startsWith('http://') &&
                              !value.startsWith('https://')) {
                            return 'URL must start with http:// or https://';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      Consumer<TeamProvider>(
                        builder: (context, provider, child) {
                          return ElevatedButton(
                            onPressed: provider.isLoading ? null : _submitEndpoint,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: provider.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Submit Endpoint',
                                    style: TextStyle(fontSize: 16),
                                  ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
