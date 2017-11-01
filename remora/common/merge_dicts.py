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
import sys # for debug

def merge_dicts(dict1, dict2):
    """Recursively merges dict2 into dict1"""
    def is_dicts(dict1, dict2):
        if not isinstance(dict1, dict) or not isinstance(dict2, dict):
            return False
        else:
            return True

    def is_lists(dict1, dict2):
        if not isinstance(dict1, list) or not isinstance(dict2, list):
            return False
        else:
            return True

    def is_str(dict1, dict2):
        if not isinstance(dict1, str) or not isinstance(dict2, str):
            return False
        else:
            return True

    def merge_lists(list1, list2):
        work1 = [e for e in list1 if isinstance(e, str)]
        work2 = [e for e in list1 if not isinstance(e, str)]

        work3 = [e for e in list2 if isinstance(e, str)]
        work4 = [e for e in list2 if not isinstance(e, str)]
        #print(work1)
        #print(work2)
        #print(work3)
        #print(work4)

        work5 = list(set(work1+work3))
        #print(work5)

        #if len(work2) == 0:
        #    print("pass")
        #    work5.append(work4)
        #else:
        for i in work2:
            m = i
            for j in work4:
                m = merge_dicts(i, j)
            work5.append(m)

        return work5

    #print("dict1" + str(type(dict1)))
    #print("dict2" + str(type(dict2)))

#    if isinstance(dict1, list) and isinstance(dict2, list):
#        for i, k in enumerate(dict2):
#            if isinstance(k, dict):
#                #for e in k.keys()
#                for j, f in enumerate(dict1):
#                    if isinstance(f, dict):
#                        w = k
#                        x = f
#                        del dict1[j]
#                        #del dict2[i]
#                        #dict2.append("dummy")
#                        dict1.append(merge_dicts(x, w))
#            else:
#                 dict1.append(k)
#        return dict1
    if isinstance(dict1, list) and isinstance(dict2, list):
        return merge_lists(dict1, dict2)
        #return dict1 + dict2

    #if not is_dicts(dict1, dict2):
    #    return dict1
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
    #print('---')
    #print(yaml_dict)
    #print('---')
    dict1 = yaml_dict['node_groups']['master_arm64']['spec']
    dict2 = yaml_dict['spec']
    #print(dict1)
    #print('---')
    #print(dict2)
    #print('---')
    result=merge_dicts(dict1, dict2)
    print(result)
    #print('---')

    
