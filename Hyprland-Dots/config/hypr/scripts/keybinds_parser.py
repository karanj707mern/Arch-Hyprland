#!/usr/bin/env python3
import sys
import re
import os

def normalize_combo(combo):
    return combo.replace(" ", "").replace("\t", "")

def extract_combo_conf(line):
    line = re.sub(r'\s*#.*$', '', line).strip()
    if '=' not in line:
        return None
    try:
        rhs = line.split('=', 1)[1]
        parts = [p.strip() for p in rhs.split(',')]
        if len(parts) < 2:
            return None
        mods = parts[0]
        key = parts[1]
        return f"{mods},{key}"
    except Exception:
        return None

def extract_combo_lua(bind_str):
    bind_str = bind_str.strip()
    if bind_str.startswith('hl.unbind('):
        bind_str = bind_str[len('hl.unbind('):-1]
    elif bind_str.startswith('hl.bind('):
        bind_str = bind_str[len('hl.bind('):-1]
    else:
        return None
    parts = [p.strip() for p in bind_str.split(',', 1)]
    if not parts:
        return None
    first = parts[0]
    combo = first.replace('mainMod', 'SUPER').replace('"', '').replace("'", '').replace(' .. ', '').replace(' + ', '+')
    return combo

def parse_lua_line(line, file_path, is_user_file, user_conf_path, binding_map, source_map, user_bind_map, unbound_user, seen_any_bind, default_seen):
    line = line.rstrip('\n')
    stripped = line.strip()
    if not stripped or stripped.startswith('--'):
        return
    is_bind = re.match(r'^\s*hl\.bind\(', line)
    is_unbind = re.match(r'^\s*hl\.unbind\(', line)
    if is_bind:
        combo = extract_combo_lua(stripped)
        if not combo:
            return
        combo = normalize_combo(combo)
        seen_any_bind[combo] = True
        if not is_user_file:
            default_seen[combo] = True
        if combo not in source_map:
            binding_map[combo] = stripped
            source_map[combo] = file_path
        if is_user_file:
            user_bind_map[combo] = stripped
            binding_map[combo] = stripped
            source_map[combo] = file_path
    elif is_unbind:
        combo = extract_combo_lua(stripped)
        if not combo:
            return
        combo = normalize_combo(combo)
        if file_path == user_conf_path:
            unbound_user[combo] = True
        if combo in binding_map:
            del binding_map[combo]
        if combo in source_map:
            del source_map[combo]

def parse_files(files):
    binding_map = {}
    source_map = {}
    user_bind_map = {}
    unbound_user = {}
    seen_any_bind = {}
    default_seen = {}
    if not files:
        return [], []
    user_conf_path = files[-1] if len(files) > 1 else None
    for file_path in files:
        if not os.path.exists(file_path):
            continue
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                for line in f:
                    if file_path.endswith('.lua'):
                        parse_lua_line(line, file_path, file_path == user_conf_path, user_conf_path, binding_map, source_map, user_bind_map, unbound_user, seen_any_bind, default_seen)
                    else:
                        line = line.rstrip('\n')
                        if not line or line.strip().startswith('#'):
                            continue
                        is_bind = re.match(r'^\s*bind[a-z]*\s*=', line)
                        is_unbind = re.match(r'^\s*unbind\s*=', line)
                        if is_bind:
                            combo_raw = extract_combo_conf(line)
                            if not combo_raw:
                                continue
                            combo = normalize_combo(combo_raw)
                            seen_any_bind[combo] = True
                            is_user_file = (file_path == user_conf_path)
                            if not is_user_file:
                                default_seen[combo] = True
                            if combo not in source_map:
                                binding_map[combo] = line
                                source_map[combo] = file_path
                            if is_user_file:
                                user_bind_map[combo] = line
                                binding_map[combo] = line
                                source_map[combo] = file_path
                        elif is_unbind:
                            combo_raw = extract_combo_conf(line)
                            if not combo_raw:
                                continue
                            combo = normalize_combo(combo_raw)
                            if file_path == user_conf_path:
                                unbound_user[combo] = True
                            if combo in binding_map:
                                del binding_map[combo]
                            if combo in source_map:
                                del source_map[combo]
        except Exception as e:
            sys.stderr.write(f"Error reading {file_path}: {e}\n")
            continue
    raw_keybinds = []
    missing_unbind_suggestions = []
    for combo in seen_any_bind:
        eff_line = binding_map.get(combo)
        src = source_map.get(combo)
        if not eff_line:
            continue
        raw_keybinds.append(eff_line)
        if src == user_conf_path and combo in default_seen and combo not in unbound_user:
            suggest = re.sub(r'^\s*bind[a-z]*', 'unbind', eff_line)
            missing_unbind_suggestions.append(suggest)
    return raw_keybinds, missing_unbind_suggestions

def format_for_rofi(raw_binds):
    formatted_lines = []
    for line in raw_binds:
        if line.strip().startswith('hl.bind('):
            match = re.match(r'^\s*hl\.bind\((.+?),\s*(.+?),\s*\{[^}]*description\s*=\s*"([^"]+)"', line)
            if match:
                combo_raw = match.group(1)
                combo = combo_raw.replace('mainMod', 'SUPER').replace('"', '').replace("'", '').replace(' .. ', '').replace(' + ', '+')
                desc = match.group(3)
                formatted_lines.append(f"{combo} — {desc}")
                continue
            match2 = re.match(r'^\s*hl\.bind\((.+?),\s*(.+)\)', line)
            if match2:
                combo_raw = match2.group(1)
                combo = combo_raw.replace('mainMod', 'SUPER').replace('"', '').replace("'", '').replace(' .. ', '').replace(' + ', '+')
                formatted_lines.append(combo)
                continue
            continue
        match = re.match(r'^\s*(bind[a-z]*)\s*=(.*)', line)
        if not match:
            continue
        binder = match.group(1).replace(" ", "").replace("\t", "")
        rhs = match.group(2).strip()
        has_desc = 'd' in binder and binder != 'bind'
        parts = [p.strip() for p in rhs.split(',')]
        if len(parts) < 2:
            continue
        mods = parts[0]
        key = parts[1]
        desc = ""
        dispatcher = ""
        params = ""
        start_idx = 0
        if has_desc:
            desc = parts[2] if len(parts) >= 3 else ""
            dispatcher = parts[3] if len(parts) >= 4 else ""
            start_idx = 4
        else:
            dispatcher = parts[2] if len(parts) >= 3 else ""
            start_idx = 3
        remaining_parts = []
        if start_idx < len(parts):
            for i in range(start_idx, len(parts)):
                if parts[i]:
                    remaining_parts.append(parts[i])
        if remaining_parts:
            params = ", ".join(remaining_parts)
        mods = mods.replace("$mainMod", "SUPER")
        mods = re.sub(r'[ \t]+', '+', mods)
        if mods and key:
            combo_str = f"{mods}+{key}"
        elif key:
            combo_str = key
        else:
            combo_str = mods
        if has_desc and desc:
            formatted_lines.append(f"{combo_str} — {desc}")
        elif dispatcher:
            if params:
                formatted_lines.append(f"{combo_str} — {dispatcher} {params}")
            else:
                formatted_lines.append(f"{combo_str} — {dispatcher}")
        else:
            formatted_lines.append(combo_str)
    return formatted_lines

def main():
    if len(sys.argv) < 2:
        sys.exit(0)
    config_files = sys.argv[1:]
    binds, suggestions = parse_files(config_files)
    if not binds:
        print("no keybinds found.")
        sys.exit(1)
    formatted = format_for_rofi(binds)
    for line in formatted:
        print(line)
    if suggestions:
        import tempfile
        try:
            with tempfile.NamedTemporaryFile(mode='w', delete=False, prefix='hypr-unbind-suggestions-', suffix='.conf') as tf:
                tf.write('\n'.join(suggestions) + '\n')
                with open("/tmp/hypr_keybind_suggestions_file", "w") as sf:
                    sf.write(tf.name)
        except Exception:
            pass

if __name__ == "__main__":
    main()
