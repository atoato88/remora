#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

import yaml
import sys

def merge_dicts(dict1, dict2):
    """Recursively merges dict2 into dict1"""
    def is_dicts(dict1, dict2):
        pass

    def is_lists(dict1, dict2):
        pass

    if not isinstance(dict1, dict) or not isinstance(dict2, dict):
        return dict1
    for k in dict2:
        if k in dict1:
            dict1[k] = merge_dicts(dict1[k], dict2[k])
        else:
            dict1[k] = dict2[k]
    return dict1


if __name__ == '__main__':
    file_path = sys.argv[1]
    dict1 = {}
    dict2 = {}
    yaml_dict = {}
    with open(file_path, 'rt') as f:
      yaml_dict = yaml.load(f)
    print('---')
    print(yaml_dict)
    print('---')
    dict1 = yaml_dict['node_groups']['master_arm64']
    dict2 = yaml_dict['spec']
    print(dict1)
    print('---')
    print(dict2)
    print('---')
    result=merge_dicts(dict1, dict2)
    print(result)
    print('---')

    
